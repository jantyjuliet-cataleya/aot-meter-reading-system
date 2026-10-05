# Tariff and Pricing Model

The billing system must support tariff updates without corrupting historical billing records.

## Recommended pricing rules
- Never overwrite the current tariff record
- Add a new tariff version when rates change
- Mark one tariff as active at a time for each meter class
- Use `effectiveFrom` and `effectiveTo` dates to determine the active rate at a specific billing period

## Example tariff schedule
```json
[
  {
    "id": "tariff-001",
    "meterType": "domestic",
    "ratePerUnit": 2.80,
    "fixedCharge": 1000,
    "effectiveFrom": "2025-01-01",
    "effectiveTo": "2026-09-30",
    "status": "inactive"
  },
  {
    "id": "tariff-002",
    "meterType": "domestic",
    "ratePerUnit": 3.25,
    "fixedCharge": 1200,
    "effectiveFrom": "2026-10-01",
    "effectiveTo": null,
    "status": "active"
  }
]
```

## Billing service behavior
- For a meter reading dated `2026-10-15`, the system picks tariff-002
- For a reading dated `2026-09-20`, it picks tariff-001
- Historical data can always be recalculated correctly using the tariff schedule at that moment

## Implementation note
The backend includes a `pricingService.js` that reads the active tariff based on the effective date and provides a `calculateBill` function.
