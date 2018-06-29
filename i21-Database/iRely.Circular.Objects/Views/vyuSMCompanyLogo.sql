CREATE VIEW [dbo].[vyuSMCompanyLogo]
	AS SELECT A.blbFile, B.strComment, B.intAttachmentId, B.strName
	 FROM dbo.tblSMUpload A 
	 INNER JOIN
     dbo.tblSMAttachment B 
	 ON A.intAttachmentId = B.intAttachmentId
