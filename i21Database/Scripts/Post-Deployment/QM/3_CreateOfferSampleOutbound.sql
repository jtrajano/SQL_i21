print('/*******************  BEGIN - Insert Control Point: Offer Sample Outbound *******************/')
GO


IF NOT EXISTS(SELECT strControlPointName
			  FROM tblQMControlPoint
			  WHERE strControlPointName = 'Offer Sample Outbound')

	BEGIN
		INSERT INTO tblQMControlPoint VALUES (15, 'Offer Sample Outbound', 'Offer Sample Outbound')
	END

GO
print('/*******************  Insert Control Point: Offer Sample Outbound   *******************/')
