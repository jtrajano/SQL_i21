CREATE VIEW [dbo].[vyuSTRegister]
AS
SELECT R.intRegisterId
    , R.intStoreId
    , R.strRegisterName
    , R.strRegisterClass
    ,S.intStoreNo 
FROM tblSTRegister R
INNER JOIN tblSTStore S ON S.intStoreId = R.intStoreId

