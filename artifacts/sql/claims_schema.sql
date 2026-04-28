-- Synthetic healthcare claims schema for portfolio demonstration.
-- This is intentionally simplified and contains no PHI.

CREATE TABLE members (
    member_id VARCHAR(20) PRIMARY KEY,
    plan_id VARCHAR(20) NOT NULL,
    effective_date DATE NOT NULL,
    termination_date DATE NULL,
    status VARCHAR(30) NOT NULL
);

CREATE TABLE providers (
    provider_id VARCHAR(20) PRIMARY KEY,
    provider_type VARCHAR(40) NOT NULL,
    network_status VARCHAR(40) NOT NULL,
    contract_start DATE NOT NULL,
    contract_end DATE NULL
);

CREATE TABLE claims (
    claim_id VARCHAR(20) PRIMARY KEY,
    member_id VARCHAR(20) NOT NULL,
    provider_id VARCHAR(20) NOT NULL,
    service_date DATE NOT NULL,
    claim_status VARCHAR(30) NOT NULL,
    billed_amount DECIMAL(12,2) NOT NULL,
    allowed_amount DECIMAL(12,2) NOT NULL,
    paid_amount DECIMAL(12,2) NOT NULL,
    duplicate_flag CHAR(1) NOT NULL,
    CONSTRAINT fk_claim_member FOREIGN KEY (member_id) REFERENCES members(member_id),
    CONSTRAINT fk_claim_provider FOREIGN KEY (provider_id) REFERENCES providers(provider_id)
);

CREATE TABLE claim_lines (
    claim_line_id VARCHAR(20) PRIMARY KEY,
    claim_id VARCHAR(20) NOT NULL,
    line_number INTEGER NOT NULL,
    procedure_code VARCHAR(20) NOT NULL,
    diagnosis_code VARCHAR(20) NOT NULL,
    billed_amount DECIMAL(12,2) NOT NULL,
    allowed_amount DECIMAL(12,2) NOT NULL,
    paid_amount DECIMAL(12,2) NOT NULL,
    line_status VARCHAR(30) NOT NULL,
    denial_reason_code VARCHAR(60) NULL,
    CONSTRAINT fk_line_claim FOREIGN KEY (claim_id) REFERENCES claims(claim_id)
);

CREATE TABLE payments (
    payment_id VARCHAR(20) PRIMARY KEY,
    claim_id VARCHAR(20) NOT NULL,
    payment_amount DECIMAL(12,2) NOT NULL,
    payment_date DATE NOT NULL,
    remittance_id VARCHAR(20) NOT NULL,
    CONSTRAINT fk_payment_claim FOREIGN KEY (claim_id) REFERENCES claims(claim_id)
);

CREATE TABLE claim_status_history (
    status_history_id VARCHAR(20) PRIMARY KEY,
    claim_id VARCHAR(20) NOT NULL,
    status_value VARCHAR(30) NOT NULL,
    status_timestamp TIMESTAMP NOT NULL,
    CONSTRAINT fk_status_claim FOREIGN KEY (claim_id) REFERENCES claims(claim_id)
);

