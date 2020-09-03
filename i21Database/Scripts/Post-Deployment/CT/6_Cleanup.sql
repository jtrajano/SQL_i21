GO
	print 'Begin drop trgCTContractDetail';

	IF  EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[trgCTContractDetail]'))
	DROP TRIGGER [dbo].[trgCTContractDetail]

	print 'End drop trgCTContractDetail';
GO