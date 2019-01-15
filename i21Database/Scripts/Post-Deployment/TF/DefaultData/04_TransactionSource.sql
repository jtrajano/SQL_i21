PRINT ('Deploying Transaction Source')

DECLARE @TransactionSource AS TABLE(intTransactionSourceId INT, strTransactionSource NVARCHAR(50), intMasterId INT)

INSERT INTO @TransactionSource(
	intTransactionSourceId
	, strTransactionSource
	, intMasterId
)
SELECT intTransactionSourceId = 1, strTransactionSource = 'Standard', intMasterId = 1
UNION SELECT intTransactionSourceId = 2, strTransactionSource = 'Transport Delivery',  intMasterId = 2
UNION ALL SELECT intTransactionSourceId = 3, strTransactionSource = 'Tank Delivery', intMasterId = 3
UNION ALL SELECT intTransactionSourceId = 4, strTransactionSource = 'CF Tran', intMasterId = 4
UNION ALL SELECT intTransactionSourceId = 5, strTransactionSource = 'CF Invoice', intMasterId = 5
UNION ALL SELECT intTransactionSourceId = 6, strTransactionSource = 'POS', intMasterId = 6
UNION ALL SELECT intTransactionSourceId = 7, strTransactionSource = 'Store Checkout', intMasterId = 7

SET IDENTITY_INSERT tblTFTransactionSource ON

UPDATE tblTFTransactionSource
	SET intMasterId = B.intMasterId
FROM @TransactionSource B
    WHERE tblTFTransactionSource.intMasterId IS NULL
	AND tblTFTransactionSource.strTransactionSource COLLATE Latin1_General_CI_AS = B.strTransactionSource COLLATE Latin1_General_CI_AS

MERGE	
INTO	tblTFTransactionSource 
WITH	(HOLDLOCK) 
AS		TARGET
USING (
	SELECT * FROM @TransactionSource
) AS SOURCE
	ON TARGET.intMasterId = SOURCE.intMasterId

WHEN MATCHED THEN 
	UPDATE
	SET 
		strTransactionSource = SOURCE.strTransactionSource
WHEN NOT MATCHED BY TARGET THEN 
	INSERT (
		intTransactionSourceId
		,strTransactionSource
		,intMasterId
	)
	VALUES (
		SOURCE.intTransactionSourceId
		, SOURCE.strTransactionSource
		, SOURCE.intMasterId
	);


SET IDENTITY_INSERT tblTFTransactionSource OFF


GO