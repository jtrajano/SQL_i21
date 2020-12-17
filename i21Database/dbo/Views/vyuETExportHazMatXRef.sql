CREATE VIEW [dbo].[vyuETExportHazMatXRef]    
AS
SELECT ICT.intTagId epa_group
           ,strItemNo item_no
FROM dbo.tblICItem ICC WITH (NOLOCK)
INNER JOIN dbo.tblICTag ICT ON ICC.intHazmatTag = ICT.intTagId AND ICT.strType = 'Hazmat Message'
WHERE ISNULL(ICC.intHazmatTag, 0) <> 0
GROUP BY intTagId, strItemNo