CREATE VIEW [dbo].[vyuIPGetConnection]
AS 
SELECT cn.intConnectionId,cn.strConnectionName,cn.strServerName,cn.strDatabaseName,st.strName AS strServerType 
From tblIPConnection cn Join tblIPServerType st on cn.intServerTypeId=st.intServerTypeId
