--liquibase formatted sql

-- changeset Von:uspAGCalculateWOTotal.1 runOnChange:true splitStatements:false
-- comment: AP-1234

CREATE OR ALTER PROCEDURE [dbo].[uspARDeleteCreditCardPrepayment]
	  @intPaymentId		INT
	, @intEntityUserId	INT
AS
BEGIN
	  
DECLARE @strParam NVARCHAR(100) = CAST(@intPaymentId AS NVARCHAR(100))
DECLARE @ysnSuccess	BIT = 0

EXEC dbo.uspARPostPayment @post = 0, @recap = 0, @param = @strParam, @userId = @intEntityUserId, @raiseError = 1, @success = @ysnSuccess OUT

IF ISNULL(@ysnSuccess, 0) = 1
	BEGIN
		DELETE FROM tblARPaymentDetail WHERE intPaymentId = @intPaymentId
		DELETE FROM tblARInvoice WHERE intPaymentId = @intPaymentId
		DELETE FROM tblARPayment WHERE intPaymentId = @intPaymentId
	END




END