CREATE TABLE dbo.tblMFCustomerLabelType
(
	intCustomerLabelTypeId INT CONSTRAINT PK_tblMFCustomerLabelType PRIMARY KEY , 
	intConcurrencyId INT NULL CONSTRAINT DF_tblMFCustomerLabelTypey_intConcurrencyId DEFAULT 0, 
	strLabelType nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	
)