CREATE TABLE [dbo].[tblMBILPayment]
(
	intPaymentId INT IDENTITY (1, 1) NOT NULL,
	intShiftId INT NOT NULL,
	strPaymentNo NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	intEntityCustomerId INT NOT NULL, 
	intEntityDriverId INT NOT NULL,
	intCompanyLocationId INT NOT NULL,
	dtmDatePaid DATETIME NULL,
	strMethod NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	strCheckNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	dblPayment NUMERIC(18, 6) DEFAULT((0)) NULL,
	strComments NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
	ysnPosted BIT DEFAULT((0)) NULL,
	intConcurrencyId INT DEFAULT((1)) NULL,
	CONSTRAINT [PK_tblMBILPayment] PRIMARY KEY CLUSTERED ([intPaymentId] ASC), 
	CONSTRAINT [FK_tblMBILPayment_tblEMEntity_Customer] FOREIGN KEY ([intEntityCustomerId]) REFERENCES [tblEMEntity]([intEntityId]),
	CONSTRAINT [FK_tblMBILPayment_tblSMCompanyLocation] FOREIGN KEY ([intCompanyLocationId]) REFERENCES [tblSMCompanyLocation]([intCompanyLocationId]), 
    CONSTRAINT [FK_tblMBILPayment_tblMBILShift] FOREIGN KEY ([intShiftId]) REFERENCES [tblMBILShift]([intShiftId]), 
    CONSTRAINT [FK_tblMBILPayment_tblEMEntity_Driver] FOREIGN KEY ([intEntityDriverId]) REFERENCES [tblEMEntity]([intEntityId]),
);
GO
