# Shared Laravel-shaped fixture for the loading evals. Each case's scaffold.sh
# sources this file, calls base_files, adds its own files, then calls base_commit.
# Files only, no vendor/ and no working app.

base_files() {
mkdir -p app/Models app/Http/Controllers app/Jobs database/migrations tests/Feature

cat > composer.json <<'EOF'
{
    "name": "acme/shop",
    "require": { "php": "^8.3", "laravel/framework": "^12.0" },
    "require-dev": { "pestphp/pest": "^3.0", "larastan/larastan": "^3.0" }
}
EOF

cat > app/Models/Order.php <<'EOF'
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Order extends Model
{
    protected $fillable = ['customer_id', 'status', 'total'];

    public function isPaid(): bool
    {
        return $this->status === 'paid';
    }
}
EOF

cat > app/Http/Controllers/OrderController.php <<'EOF'
<?php

namespace App\Http\Controllers;

use App\Models\Order;

class OrderController extends Controller
{
    public function index()
    {
        return Order::where('status', 'pending')->get();
    }

    public function ship(Order $order)
    {
        if ($order->status !== 'paid') {
            abort(422, 'Only paid orders can ship.');
        }

        $order->update(['status' => 'shipped']);

        return $order;
    }
}
EOF

cat > app/Jobs/ShipOrder.php <<'EOF'
<?php

namespace App\Jobs;

use App\Models\Order;

class ShipOrder
{
    public function __construct(public Order $order) {}

    public function handle(): void
    {
        if ($this->order->status === 'shipped') {
            return;
        }

        $this->order->update(['status' => 'shipped']);
    }
}
EOF

cat > database/migrations/2025_01_01_000000_create_orders_table.php <<'EOF'
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('orders', function (Blueprint $table) {
            $table->id();
            $table->foreignId('customer_id');
            $table->string('status')->default('pending');
            $table->unsignedInteger('total');
            $table->timestamps();
        });
    }
};
EOF

cat > tests/Feature/OrderTest.php <<'EOF'
<?php

use App\Models\Order;

it('ships a paid order', function () {
    $order = Order::factory()->create(['status' => 'paid']);

    $this->post("/orders/{$order->id}/ship")->assertOk();

    expect($order->fresh()->status)->toBe('shipped');
});
EOF

mkdir -p docs
cat > docs/conventions.md <<'EOF'
# Conventions

- Tests are Pest feature tests that call the route and assert the stored state.
- Status columns are backed enums, cast on the model.
- Jobs that write orders implement ShouldBeUnique.
- Read the real error in storage/logs/laravel.log before changing code.
EOF
}

base_commit() {
git init -q -b main
git add -A
git_eval commit -qm "${1:-initial shop}"
}

git_eval() {
git -c user.name=eval -c user.email=eval@example.com "$@"
}
