CREATE TABLE [dbo].[tblMBILPayment]
(
	intPaymentId INT IDENTITY (1, 1) NOT NULL,
	intEntityCustomerId INT Not NUll, 
	intEntityDriverId int not null,
	intCompanyLocationId int not null,
	CONSTRAINT [PK_dbo.tblMBILPayment] PRIMARY KEY CLUSTERED ([intPaymentId] ASC), 
	CONSTRAINT [FK_tblMBILPayment_tblARCustomer] FOREIGN KEY ([intEntityCustomerId]) REFERENCES [tblARCustomer]([intEntityId]),
	CONSTRAINT [FK_tblMBILPayment_tblARSalesperson] FOREIGN KEY (intEntityDriverId) REFERENCES [tblARSalesperson]([intEntityId]),
	CONSTRAINT [FK_tblMBILPayment_tblSMCompanyLocation] FOREIGN KEY ([intCompanyLocationId]) REFERENCES [tblSMCompanyLocation]([intCompanyLocationId]),
);
GO
