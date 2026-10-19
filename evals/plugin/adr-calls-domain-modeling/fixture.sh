#!/usr/bin/env bash
# A repo with a glossary and no ADRs yet.
set -euo pipefail
git init -q
cat > GLOSSARY.md <<'MD'
# Shop

Online shop: customers place orders, billing invoices them.

## Language

**Order**:
A customer's request to buy items, from placement to delivery.
_Avoid_: Purchase, cart

**Invoice**:
A request for payment sent to a customer after delivery.
_Avoid_: Bill
MD
