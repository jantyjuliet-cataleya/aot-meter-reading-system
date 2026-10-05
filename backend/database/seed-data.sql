-- Sample data for testing and demonstration

-- Insert sample officers
INSERT INTO officers (officer_name, employee_number, phone, email, status)
VALUES 
    ('John Mensah', 'EMP-001', '+233501234567', 'john.mensah@aot.gov.gh', 'active'),
    ('Ama Owusu', 'EMP-002', '+233502345678', 'ama.owusu@aot.gov.gh', 'active'),
    ('Kwasi Amponsah', 'EMP-003', '+233503456789', 'kwasi.amponsah@aot.gov.gh', 'active'),
    ('Akosua Boateng', 'EMP-004', '+233504567890', 'akosua.boateng@aot.gov.gh', 'active');

-- Insert sample customers
INSERT INTO customers (customer_number, account_number, customer_name, address, plot_no, service_area, service_type, index_number, status)
VALUES 
    ('CUST/AP/2012-001', '2012-5708-AP-001', 'Org. Abokobi Presby Mission', 'P.O. Box 155', '001', 'Abokobi', 'Domestic', '5', 'active'),
    ('CUST/AB/2022-001', '2022-7503-DC-001', 'Mr Dzofzoxen Charles', 'Abokobi Town', '002', 'Abokobi', 'Domestic', '838', 'active'),
    ('CUST/AB/2017-002', '2017-3917-FB-001', 'Org. Field Block Factory', 'Industrial Area', '003', 'Abokobi', 'Commercial', '473', 'active'),
    ('CUST/AB/2018-003', '2018-1118-DN-001', 'Mr David Nortem', 'Residential Area', '004', 'Abokobi', 'Domestic', '540', 'active'),
    ('CUST/AB/2019-004', '2019-3026-RA-001', 'Madam Rita Agyei', 'Main Street', '005', 'Abokobi', 'Domestic', '558', 'active'),
    ('CUST/AB/2017-005', '2017-8706-GG-001', 'Mrs. Gladys Gomez', 'North Road', '006', 'Abokobi', 'Domestic', '500', 'active'),
    ('CUST/AB/2018-006', '2018-8215-GO-001', 'Mr George Obeang', 'South Road', '007', 'Abokobi', 'Domestic', '545', 'active'),
    ('CUST/AB/2016-007', '2016-3512-EK-001', 'Mr Benjamin L. Kuormton', 'East Area', '008', 'Abokobi', 'Domestic', '451', 'active'),
    ('CUST/AB/2021-008', '2021-9701-MQ-000', 'Mr Michael Quaye', 'West Area', '009', 'Abokobi', 'Institution', '712', 'active'),
    ('CUST/AB/2020-009', '2020-3626-VM-001', 'Madam Vida Marquaye M2', 'Central Area', '010', 'Abokobi', 'Domestic', '502', 'active');

-- Insert sample meters
INSERT INTO meters (meter_number, customer_id, installation_date, service_area, meter_status, current_reading, previous_reading)
VALUES 
    ('H140500017', (SELECT id FROM customers WHERE customer_number = 'CUST/AP/2012-001'), '2020-01-15', 'Abokobi', 'active', 4800, 4380),
    ('2021-04-02101', (SELECT id FROM customers WHERE customer_number = 'CUST/AB/2022-001'), '2021-04-02', 'Abokobi', 'active', 4342, 4341),
    ('2014-0721267', (SELECT id FROM customers WHERE customer_number = 'CUST/AB/2017-002'), '2014-07-12', 'Abokobi', 'active', 7143, 7104),
    ('17060193', (SELECT id FROM customers WHERE customer_number = 'CUST/AB/2018-003'), '2017-06-01', 'Abokobi', 'active', 2068, 2061),
    ('2021-04-01532', (SELECT id FROM customers WHERE customer_number = 'CUST/AB/2019-004'), '2021-04-01', 'Abokobi', 'active', 747, 746),
    ('2014-07-20811', (SELECT id FROM customers WHERE customer_number = 'CUST/AB/2017-005'), '2014-07-20', 'Abokobi', 'active', 2620, 2620),
    ('16060137', (SELECT id FROM customers WHERE customer_number = 'CUST/AB/2017-006'), '2016-06-01', 'Abokobi', 'active', 1735, 1733),
    ('130803539', (SELECT id FROM customers WHERE customer_number = 'CUST/AB/2018-006'), '2013-08-03', 'Abokobi', 'active', 4081, 4081),
    ('2014-06-12271', (SELECT id FROM customers WHERE customer_number = 'CUST/AB/2016-007'), '2014-06-12', 'Abokobi', 'active', 1337, 1329),
    ('2020-06-00032', (SELECT id FROM customers WHERE customer_number = 'CUST/AB/2021-008'), '2020-06-00', 'Abokobi', 'active', 63, 60);

-- Insert sample tariffs
INSERT INTO tariffs (service_type, rate_per_unit, fixed_charge, water_expansion_percentage, fire_fighting_percentage, effective_from, effective_to, status)
VALUES 
    ('Domestic', 2.80, 1000, 2, 1, '2025-01-01', '2026-09-30', 'inactive'),
    ('Domestic', 3.25, 1200, 2, 1, '2026-10-01', NULL, 'active'),
    ('Commercial', 4.50, 2000, 2, 1, '2026-10-01', NULL, 'active'),
    ('Institution', 5.10, 2500, 2, 1, '2026-10-01', NULL, 'active');
