print('/*******************  BEGIN - Update Company Location ID of Sample *******************/')
GO


UPDATE tblQMSample
SET intCompanyLocationId = intLocationId
WHERE intCompanyLocationId IS NULL;

GO
print('/*******************  END OF - Update Company Location ID of Sample  *******************/')
