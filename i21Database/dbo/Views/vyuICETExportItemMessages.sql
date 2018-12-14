CREATE VIEW [dbo].[vyuICETExportItemMessages]
	AS SELECT 	 imsgno = strItemNo
				,imsg1 = strInvoiceComments
				,imsg2 = '' COLLATE Latin1_General_CI_AS
				,imsg3 = '' COLLATE Latin1_General_CI_AS
				,iamsgno = 0
	FROM tblICItem
