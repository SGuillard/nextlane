# Sales Deal / Quote

The DMS slice this project builds: a salesperson assembles a priced offer for a
customer to buy a vehicle, sends it, and the customer accepts, declines, or lets
it expire.

## Language

**Quote**:
The aggregate. A priced offer for one customer to buy one vehicle, made up of
line items and an optional trade-in. Owns its own lifecycle.
_Avoid_: Deal, order, proposal, estimate

**Customer**:
The person or organization the quote is addressed to — the prospective buyer.
_Avoid_: Client, lead, account

**Vehicle**:
The car the quote is for.
_Avoid_: Car, unit, stock item

**Line item**:
One priced row on a quote — the vehicle price, an option, a fee. A quote has one
or more.
_Avoid_: Row, entry, charge

**Trade-in**:
A vehicle the customer gives back, credited against the quote total. Zero or one
per quote.
_Avoid_: Part-exchange, swap

**Discount**:
A reduction applied to the quote total, separate from line items.
_Avoid_: Rebate, markdown

**Total**:
The amount the customer pays: the sum of line items minus the discount (and the
trade-in credit). Always derived, never stored as an independent fact.
_Avoid_: Price, grand total, amount due

## Lifecycle

A quote moves forward only through these states; it never moves back.

**Draft**: being assembled, freely editable.
**Sent**: delivered to the customer, no longer editable.
**Accepted**: the customer agreed. Terminal.
**Declined**: the customer refused. Terminal.
**Expired**: the customer did neither in time. Terminal.
