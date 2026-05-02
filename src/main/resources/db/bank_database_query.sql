SELECT * FROM sec_ref;
SELECT * FROM accounts;
SELECT * FROM positions;
SELECT * FROM orders;
SELECT * FROM transactions;

-- Prepare Account wise Positions Report
-- Report should contains acct_id, posn_id, sec_id, avg_unit_price_in_sec_ccy, avg_unit_price_in_acct_ccy, biz_date 
 
SELECT 
	acct.account_id   as account_id,
    posn.position_id  as position_id,
    sec.security_id   as security_id
FROM 
(
	SELECT
        acct_id  as account_id,
        acct_ccy as account_currency
	FROM
		ACCOUNTS
	WHERE biz_date = (SELECT MAX(biz_date) FROM ACCOUNTS)
    AND is_active = 1
) as acct
LEFT JOIN
(
	SELECT
		posn_id as position_id,
        acct_id as account_id,
        sec_id  as security_id
	FROM
		POSITIONS
	WHERE biz_date = (SELECT MAX(biz_date) FROM POSITIONS)
) as posn
ON acct.account_id = posn.account_id
LEFT JOIN
(
	SELECT
        sec_id     as security_id,
        sec_name   as security_name,
        unit_price as unit_price,
        sec_ccy    as security_currency
	FROM
		SEC_REF
	WHERE is_active = 1
) as sec
ON posn.security_id = sec.security_id
ORDER BY acct.account_id;


SELECT * FROM sec_ref