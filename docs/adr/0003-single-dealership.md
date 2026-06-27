# Single dealership, no multi-tenancy

The app serves one dealership's staff: all authenticated users share the same
`Customer`/`Vehicle`/`Quote` pool, with `createdBy` for attribution and no
row-level access control. Multi-tenancy is deliberately out of scope. The
brief's "dealers" refers to the product's market, not a requirement to isolate
data per dealership in this slice.

## Why not design for it now

Adding a speculative tenant column or a premature data-access abstraction would
be generality we don't yet need — exactly the kind of thing a reviewer should
push back on. We keep the code single-tenant and instead write down the path, so
the deferral is a known, bounded change rather than a surprise.

## The migration path, if it is ever needed

1. Add a `Dealership` table and seed the one existing dealership.
2. Add a `dealershipId` FK to `Customer`, `Vehicle`, `Quote` (nullable), backfill
   every existing row to the single dealership, then make it required.
3. Inject the tenant filter at one data-access point and scope auth to the
   user's dealership.

This is backfill-and-filter, not a redesign. An agent can execute it from this
ADR through the normal gate.
