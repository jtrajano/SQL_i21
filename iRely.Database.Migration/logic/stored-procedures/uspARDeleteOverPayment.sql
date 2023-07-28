--liquibase formatted sql

-- changeset Von:uspAGCalculateWOTotal.1 runOnChange:true splitStatements:false
-- comment: AP-1234

CREATE OR ALTER PROCEDURE [dbo].[uspARDeleteOverPayment]
	  @PaymentId	AS INT
	, @UserId		AS INT			= 1
AS
BEGIN

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

WHILE EXISTS (SELECT TOP 1 NULL FROM tblARInvoice WHERE intPaymentId = @PaymentId AND strTransactionType = 'Overpayment')
	BEGIN
		DECLARE @intInvoiceId	INT = NULL

		SELECT TOP 1 @intInvoiceId = intInvoiceId
		FROM tblARInvoice 
		WHERE intPaymentId = @PaymentId 
		  AND strTransactionType = 'Overpayment'

		UPDATE tblARInvoice
		SET ysnPosted = 0
		WHERE intInvoiceId = @intInvoiceId

		EXEC dbo.uspARDeleteInvoice @intInvoiceId, @UserId
	END
		                     
RETURN 1

END