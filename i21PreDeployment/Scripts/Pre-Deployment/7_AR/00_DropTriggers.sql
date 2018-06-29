PRINT '********************** BEGIN - Temporarily Drop AR Triggers **********************'
GO

IF  EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[trg_tblARPaymentDelete]'))
DROP TRIGGER [dbo].[trg_tblARPaymentDelete]
GO

IF  EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[trg_tblARPaymentUpdate]'))
DROP TRIGGER [dbo].[trg_tblARPaymentUpdate]
GO

IF  EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[trg_tblARPaymentDetailUpdate]'))
DROP TRIGGER [dbo].[trg_tblARPaymentDetailUpdate]
GO

PRINT ' ********************** END - Temporarily Drop AR Triggers **********************'
GO