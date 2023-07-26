IF EXISTS(SELECT TOP 1 1 FROM tblRKSummaryLog WHERE strTransactionType = 'Transfer Storage')
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblRKSummaryLog WHERE strNotes = 'Amend Action. See GRN-3539 for additional information.')
	BEGIN
		PRINT 'START amendment of Action in Summary log for Transfer Storage from Customer to customer owned'
		SELECT DISTINCT strBucketType
			,strTransactionNumber
			,strDistributionType
			,ST.ysnDPOwnedType
		INTO #Transfer1
		FROM tblRKSummaryLog RK
		INNER JOIN tblGRStorageType ST
			ON ST.strStorageTypeDescription = RK.strDistributionType
				AND ST.ysnDPOwnedType = 0
				AND ST.strOwnedPhysicalStock = 'Customer'
		WHERE intActionId = 33
			AND strTransactionType = 'Transfer Storage'
			AND strBucketType = 'Customer Owned'

		SELECT DISTINCT strBucketType
			,strTransactionNumber
			,strDistributionType
			,ST.ysnDPOwnedType
		INTO #Transfer2
		FROM tblRKSummaryLog RK
		INNER JOIN tblGRStorageType ST
			ON ST.strStorageTypeDescription = RK.strDistributionType
				AND ST.ysnDPOwnedType = 0
				AND ST.strOwnedPhysicalStock = 'Customer'
		WHERE intActionId = 9
			AND strTransactionType = 'Transfer Storage'
			AND strBucketType = 'Customer Owned'

		SELECT DISTINCT strTransactionNumber
		INTO #Transfer3
		FROM tblRKSummaryLog RK
		INNER JOIN tblGRStorageType ST
			ON ST.strStorageTypeDescription = RK.strDistributionType
				AND ST.ysnDPOwnedType = 1
				AND ST.strOwnedPhysicalStock = 'Company'
		WHERE RK.strTransactionType = 'Transfer Storage'
			AND RK.strBucketType = 'Company Owned'

		SELECT a.strTransactionNumber
		INTO #TransferFinal
		FROM #Transfer1 a
		INNER JOIN #Transfer2 b
			ON b.strTransactionNumber = a.strTransactionNumber
		WHERE a.ysnDPOwnedType = b.ysnDPOwnedType
			AND a.strTransactionNumber NOT IN (SELECT strTransactionNumber FROM #Transfer3) 

		UPDATE RK
		SET strAction = 'Customer owned to Customer owned Storage'
			,intActionId = 74
			,strNotes = 'Amend Action. See GRN-3539 for additional information.'
		FROM tblRKSummaryLog RK
		INNER JOIN #TransferFinal TS
			ON TS.strTransactionNumber = RK.strTransactionNumber

		DROP TABLE #Transfer1
		DROP TABLE #Transfer2
		DROP TABLE #Transfer3
		DROP TABLE #TransferFinal
		PRINT 'END amendment of Action in Summary log for Transfer Storage from Customer to customer owned'
	END
END