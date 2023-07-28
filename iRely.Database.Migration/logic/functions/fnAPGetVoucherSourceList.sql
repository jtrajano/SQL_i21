--liquibase formatted sql

-- changeset Von:fnAPGetVoucherSourceList.sql.1 runOnChange:true splitStatements:false
-- comment: RK-1234

CREATE OR ALTER FUNCTION [dbo].[fnAPGetVoucherSourceList]()
RETURNS @returntable TABLE
(
     [strVoucherSource] NVARCHAR(100) COLLATE Latin1_General_CI_AS
)
AS
BEGIN
    INSERT @returntable([strVoucherSource])
    SELECT 'Voucher'
    INSERT @returntable([strVoucherSource])
    SELECT 'Debit Memo'
    INSERT @returntable([strVoucherSource])
    SELECT 'Vendor Prepayment'
    INSERT @returntable([strVoucherSource])
    SELECT 'Claim'
    INSERT @returntable([strVoucherSource])
    SELECT 'Basis Advance'
    RETURN
END



