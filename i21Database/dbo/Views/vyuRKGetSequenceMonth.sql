CREATE VIEW vyuRKGetSequenceMonth
AS
SELECT CONVERT(INT,ROW_NUMBER() OVER(ORDER BY CONVERT(DATETIME,'01 '+strDeliveryMonth))) intDeliveryMonthId,* FROM (
SELECT RIGHT(CONVERT(VARCHAR(11),DATEADD(dd, -1, DATEADD(month, n.n + DATEDIFF(month, 0, getdate()),0)),6),6) as strDeliveryMonth
FROM (SELECT TOP(12) n = ROW_NUMBER() OVER (ORDER BY name) FROM master.dbo.syscolumns) n)t