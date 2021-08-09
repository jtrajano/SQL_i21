CREATE PROCEDURE uspIPGetTestMsg @strCompany NVARCHAR(50) = ''
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

SELECT '<?xml version="1.0" encoding="utf-8"?><root><data><header><string>Hello i21</string></header></data></root>' AS strMessage
	,'Test Message: ' + @strCompany AS strInfo1
	,'1' AS strInfo2
