/*
## Overview
Type the overview for the table here. 

## Fields, description, and mapping. 
*	Type the field name here
	Type the description of the field here
	Maps: Type the mapping to origin. Type None if not applicable.


## Source Code:
*/
	CREATE TABLE [dbo].[tblICItemCustomerXref]
	(
		[intItemCustomerXrefId] INT NOT NULL IDENTITY , 
		[intItemId] INT NOT NULL, 
		[intLocationId] INT NOT NULL, 
		[intCustomerId] INT NOT NULL, 
		[strCustomerProduct] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
		[strProductDescription] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL, 
		[strPickTicketNotes] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL, 
		[intSort] INT NULL, 
		[intConcurrencyId] INT NULL DEFAULT ((0)), 
		CONSTRAINT [PK_tblICItemCustomerXref] PRIMARY KEY ([intItemCustomerXrefId]), 
		CONSTRAINT [FK_tblICItemCustomerXref_tblICItem] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem]([intItemId]) ON DELETE CASCADE, 
		CONSTRAINT [FK_tblICItemCustomerXref_tblICItemLocation] FOREIGN KEY ([intLocationId]) REFERENCES [tblICItemLocation]([intItemLocationId]),
		CONSTRAINT [FK_tblICItemCustomerXref_tblARCustomer] FOREIGN KEY ([intCustomerId]) REFERENCES [tblARCustomer]([intCustomerId])
	)

	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Identity Field',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItemCustomerXref',
		@level2type = N'COLUMN',
		@level2name = N'intItemCustomerXrefId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Item Id',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItemCustomerXref',
		@level2type = N'COLUMN',
		@level2name = N'intItemId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Location Id',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItemCustomerXref',
		@level2type = N'COLUMN',
		@level2name = N'intLocationId'
	GO

	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Customer Id',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItemCustomerXref',
		@level2type = N'COLUMN',
		@level2name = N'intCustomerId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Customer Product',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItemCustomerXref',
		@level2type = N'COLUMN',
		@level2name = N'strCustomerProduct'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Product Description',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItemCustomerXref',
		@level2type = N'COLUMN',
		@level2name = N'strProductDescription'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Pick Ticket Notes',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItemCustomerXref',
		@level2type = N'COLUMN',
		@level2name = N'strPickTicketNotes'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Sort Field',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItemCustomerXref',
		@level2type = N'COLUMN',
		@level2name = N'intSort'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Concurrency Field',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItemCustomerXref',
		@level2type = N'COLUMN',
		@level2name = N'intConcurrencyId'