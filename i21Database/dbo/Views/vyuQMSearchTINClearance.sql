CREATE VIEW vyuQMSearchTINClearance
AS
SELECT intTINClearanceId		= TIN.intTINClearanceId	 
     , strTINNumber 			= TIN.strTINNumber
	 , intCompanyLocationId		= TIN.intCompanyLocationId
	 , intBatchId				= TIN.intBatchId
	 , ysnEmpty					= ISNULL(TIN.ysnEmpty, 0)
	 , strLocationName			= CL.strLocationName
	 , strBatchId				= B.strBatchId
	 , dblTotalQuantity			= ISNULL(B.dblTotalQuantity, 0)
FROM tblQMTINClearance TIN
LEFT JOIN tblSMCompanyLocation CL ON TIN.intCompanyLocationId = CL.intCompanyLocationId
LEFT JOIN tblMFBatch B ON B.intBatchId = TIN.intBatchId