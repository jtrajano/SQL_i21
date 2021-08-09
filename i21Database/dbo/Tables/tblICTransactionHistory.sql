CREATE TABLE tblICTransactionHistory (
	intTransactionHistoryId INT NOT NULL IDENTITY(1, 1),
	dtmLastUpdate DATETIME NOT NULL,
	CONSTRAINT tblICTransactionHistory_intTransactionHistoryId
		PRIMARY KEY (intTransactionHistoryId)
)

GO