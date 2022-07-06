CREATE PROCEDURE [dbo].[uspGRTransferFixDissection]
	@TransferTransaction nvarchar(20)
	,@ShowAll bit = 0
	,@ShowPart1 bit = 1
	,@ShowPart2 bit = 1
	,@MoreInfo bit = 0
as 
begin
	

	-- Start Dissection
	declare @Total_1 decimal(24, 10)
			,@Total_2 decimal(24, 10)
			,@Total_3 decimal(24, 10)
			,@Total_3_2 decimal(24, 10)
			,@Total_4 decimal(24, 10)

	if @ShowPart1 = 1
	begin
		--Transfer
		--declare @TransferTransaction nvarchar(20) = 'TRA-309' --'TRA-957' 
		SELECT   TOP 100 PERCENT
			--'1 Transfer'
			--,strTransactionNumber
			@Total_1 = SUM(B.dblTransferTotal)-- AS dblClearingAmount 
			--,SUM(dblReceiptTotal)
			--,sum(dblTransferQty)
		FROM (
			SELECT 
			
				dblReceiptTotal
				,dblReceiptQty
				,dblTransferTotal
				,(dblTransferQty)
				,strTransactionNumber 

			FROM vyuGRTransferClearing traClr
			CROSS APPLY tblSMStartingNumber pfxTRA
			WHERE 
				strTransferStorageTicket IS NOT NULL
			AND pfxTRA.intStartingNumberId = 72
			AND traClr.strTransactionNumber LIKE pfxTRA.strPrefix + '%'
			--AND traClr.strTransactionNumber = 'TRA-520'
			UNION ALL
			SELECT 
				SUM(dblReceiptTotal)
				,sum(dblReceiptQty)
				,SUM(dblTransferTotal)
				,sum(dblTransferQty)			
				,strTransferStorageTicket 

			FROM vyuGRTransferClearing traClr
			CROSS APPLY tblSMStartingNumber pfxRct
			WHERE 
				strTransferStorageTicket IS NOT NULL
			AND pfxRct.intStartingNumberId = 23
			AND traClr.strTransactionNumber LIKE pfxRct.strPrefix + '%'
			--AND traClr.strTransferStorageTicket = 'TRA-520'
			GROUP BY traClr.strTransferStorageTicket
		) B  

		where strTransactionNumber = @TransferTransaction

		GROUP BY   
		strTransactionNumber
		ORDER BY strTransactionNumber

		if @ShowAll = 1
	
			-- Show all
			SELECT   TOP 100 PERCENT
				'1 Transfer - show all'
				,strTransactionNumber
				,(B.dblTransferTotal) AS dblClearingAmount 
				,*
			FROM (
				SELECT 
					dblReceiptTotal
					,dblReceiptQty
					,dblTransferTotal
					,dblTransferQty
					,strTransactionNumber 
				FROM vyuGRTransferClearing traClr
				CROSS APPLY tblSMStartingNumber pfxTRA
				WHERE 
					strTransferStorageTicket IS NOT NULL
				AND pfxTRA.intStartingNumberId = 72
				AND traClr.strTransactionNumber LIKE pfxTRA.strPrefix + '%'
				--AND traClr.strTransactionNumber = 'TRA-520'
				UNION ALL
				SELECT 
					(dblReceiptTotal)
					,dblReceiptQty
					,(dblTransferTotal)
					,dblTransferQty			
					,strTransferStorageTicket 
				FROM vyuGRTransferClearing traClr
				CROSS APPLY tblSMStartingNumber pfxRct
				WHERE 
					strTransferStorageTicket IS NOT NULL
				AND pfxRct.intStartingNumberId = 23
				AND traClr.strTransactionNumber LIKE pfxRct.strPrefix + '%'
				--AND traClr.strTransferStorageTicket = 'TRA-520'
				--GROUP BY traClr.strTransferStorageTicket
			) B  

			where strTransactionNumber = @TransferTransaction

			--GROUP BY   
			--strTransactionNumber
			ORDER BY B.strTransactionNumber



		--Receipt



		SELECT  TOP 100 PERCENT
			@Total_2 = SUM(B.dblReceiptTotal)--AS dblClearingAmount 
		FROM (
			SELECT 
				SUM(dblReceiptTotal) AS dblReceiptTotal,
				0 AS dblTransferTotal,
				strTransactionNumber  as strTransactionNumber
			FROM vyuGRTransferClearing traClr
			CROSS APPLY tblSMStartingNumber pfxTRA
			WHERE 
				strTransferStorageTicket IS NULL
			AND pfxTRA.intStartingNumberId = 72
			AND traClr.strTransactionNumber LIKE pfxTRA.strPrefix + '%'
			--AND traClr.strTransactionNumber = 'TRA-520'
			GROUP BY traClr.strTransactionNumber 
			UNION ALL --CHARGE
			SELECT 
				SUM(dblReceiptChargeTotal) AS dblReceiptTotal,
				0 AS dblTransferTotal,
				strTransactionNumber 
			FROM vyuGRTransferChargesClearing traClr
			CROSS APPLY tblSMStartingNumber pfxTRA
			WHERE 
				strTransferStorageTicket IS NULL
			AND pfxTRA.intStartingNumberId = 72
			AND traClr.strTransactionNumber LIKE pfxTRA.strPrefix + '%'
			--AND traClr.strTransactionNumber = 'TRA-520'
			GROUP BY traClr.strTransactionNumber--   + TEST
			UNION ALL 
			SELECT DISTINCT
				SUM(traClr.dblReceiptTotal),
				0,
				strTransferStorageTicket
			FROM vyuGRTransferClearing rctClr
			CROSS APPLY tblSMStartingNumber pfxRct
			OUTER APPLY (
				SELECT
					tmptraClr.dblReceiptTotal
				FROM vyuGRTransferClearing tmptraClr
				WHERE
					tmptraClr.strTransactionNumber = rctClr.strTransactionNumber
				AND tmptraClr.strTransferStorageTicket IS NULL
				UNION ALL --CHARGE
				SELECT
					tmptraClr.dblReceiptChargeTotal
				FROM vyuGRTransferChargesClearing tmptraClr
				WHERE
					tmptraClr.strTransactionNumber = rctClr.strTransactionNumber
				AND tmptraClr.strTransferStorageTicket IS NULL
			) traClr
			WHERE 
				pfxRct.intStartingNumberId = 23
			AND strTransferStorageTicket IS NOT NULL
			AND rctClr.strTransactionNumber LIKE pfxRct.strPrefix + '%'
			--AND rctClr.strTransferStorageTicket = 'TRA-520'			
			AND rctClr.strMark <> '2.3'
			GROUP BY rctClr.strTransferStorageTicket 
		) B  
	
		where strTransactionNumber = @TransferTransaction
		GROUP BY   
		strTransactionNumber
		ORDER BY strTransactionNumber
	
		if @ShowAll = 1
		--Show all
			SELECT  TOP 100 PERCENT
				'2 Receipt show all'
				,strTransactionNumber
				,(B.dblReceiptTotal) AS dblClearingAmount 
				,*
			FROM (
				SELECT 
					(dblReceiptTotal) AS dblReceiptTotal,
					0 AS dblTransferTotal,
					strTransactionNumber ,
					strTransferStorageTicket  as flag
				FROM vyuGRTransferClearing traClr
				CROSS APPLY tblSMStartingNumber pfxTRA
				WHERE 
					strTransferStorageTicket IS NULL
				AND pfxTRA.intStartingNumberId = 72
				AND traClr.strTransactionNumber LIKE pfxTRA.strPrefix + '%'
				--AND traClr.strTransactionNumber = 'TRA-520'
				--GROUP BY traClr.strTransactionNumber 
				UNION ALL --CHARGE
				SELECT 
					(dblReceiptChargeTotal) AS dblReceiptTotal,
					0 AS dblTransferTotal,
					strTransactionNumber ,
					strTransferStorageTicket  as flag
				FROM vyuGRTransferChargesClearing traClr
				CROSS APPLY tblSMStartingNumber pfxTRA
				WHERE 
					strTransferStorageTicket IS NULL
				AND pfxTRA.intStartingNumberId = 72
				AND traClr.strTransactionNumber LIKE pfxTRA.strPrefix + '%'
		
		
				UNION ALL 
				SELECT DISTINCT
					(traClr.dblReceiptTotal),
					0,
					strTransferStorageTicket ,
					strTransactionNumber  as flag
				FROM vyuGRTransferClearing rctClr
				CROSS APPLY tblSMStartingNumber pfxRct
				OUTER APPLY (
					SELECT
						tmptraClr.dblReceiptTotal
					FROM vyuGRTransferClearing tmptraClr
					WHERE
						tmptraClr.strTransactionNumber = rctClr.strTransactionNumber
					AND tmptraClr.strTransferStorageTicket IS NULL
					UNION ALL --CHARGE
					SELECT
						tmptraClr.dblReceiptChargeTotal
					FROM vyuGRTransferChargesClearing tmptraClr
					WHERE
						tmptraClr.strTransactionNumber = rctClr.strTransactionNumber
					AND tmptraClr.strTransferStorageTicket IS NULL
				) traClr
				WHERE 
					pfxRct.intStartingNumberId = 23
				AND strTransferStorageTicket IS NOT NULL
				AND rctClr.strTransactionNumber LIKE pfxRct.strPrefix + '%'
				AND rctClr.strMark <> '2.3'
				--AND rctClr.strTransferStorageTicket = 'TRA-520'
				--GROUP BY rctClr.strTransferStorageTicket
			) B  
	
			where strTransactionNumber = @TransferTransaction
			--GROUP BY strTransactionNumber
			ORDER BY B.strTransactionNumber
	end 
	


	if @ShowPart2 = 1
	begin
		----
		--GL
		--IR TRA
		select @Total_3 = sum(A.dblClearingTotal) from (
			SELECT DISTINCT 			
				traClr.strTransferStorageTicket
				,SUM(ISNULL(glTRA.dblTotal,0)) AS dblClearingTotal
			FROM vyuGRTransferClearing traClr
			CROSS APPLY tblSMStartingNumber pfxTRA
			CROSS APPLY tblSMStartingNumber pfxRct
			OUTER APPLY (
				select 			
					gd.strTransactionId
					,[dblTotal]  = sum((isnull(gd.dblCredit, 0) - isnull(gd.dblDebit, 0)) * case when gd.strCode = 'TRC' then -1 else 1 end )
				from 
					tblGLDetail gd
				INNER JOIN vyuGLAccountDetail acnt ON gd.intAccountId = acnt.intAccountId
				where
					gd.strTransactionId = traClr.strTransactionNumber
				and gd.ysnIsUnposted = 0 
				and acnt.intAccountCategoryId = 45
				and gd.ysnIsUnposted = 0 
				group by 
					gd.strTransactionId
			) glTRA
			WHERE 
				pfxTRA.intStartingNumberId = 72
			AND pfxRct.intStartingNumberId = 23
			AND traClr.strTransferStorageTicket LIKE pfxTRA.strPrefix + '%'
			AND traClr.strTransactionNumber LIKE pfxRct.strPrefix + '%'
			--AND traClr.strTransferStorageTicket = 'TRA-520'
			and ( traClr.strTransferStorageTicket = @TransferTransaction)				
			AND traClr.strMark <> '2.3'
			GROUP BY traClr.strTransferStorageTicket
			UNION ALL
			--TRA
			SELECT DISTINCT 
				--'3.2 GL IR TRA'
				traClr.strTransactionNumber
				--@Total_3_2 = sum(ISNULL(glTRA.dblTotal,0))-- AS dblClearingTotal
				,(ISNULL(glTRA.dblTotal,0)) AS dblClearingTotal

			FROM vyuGRTransferClearing traClr
			CROSS APPLY tblSMStartingNumber pfxTRA
			OUTER APPLY (
				select 			
					gd.strTransactionId
					,[dblTotal]  = sum((isnull(gd.dblCredit, 0) - isnull(gd.dblDebit, 0)) * case when gd.strCode = 'TRC' then -1 else 1 end )
				from 
					tblGLDetail gd
				INNER JOIN vyuGLAccountDetail acnt ON gd.intAccountId = acnt.intAccountId
				where
					gd.strTransactionId = traClr.strTransactionNumber
				and gd.ysnIsUnposted = 0 
				and acnt.intAccountCategoryId = 45
				and gd.ysnIsUnposted = 0 
				group by 
					gd.strTransactionId
			) glTRA
			WHERE 
				pfxTRA.intStartingNumberId = 72
			AND traClr.strTransactionNumber LIKE pfxTRA.strPrefix + '%'					
			AND traClr.strMark <> '2.3'
			AND glTRA.dblTotal <> 0
			and ( traClr.strTransactionNumber = @TransferTransaction)
		) A


	
		if @ShowAll = 1
		begin
			SELECT DISTINCT 
				'3.1 GL IR TRA show all'
				,traClr.strTransactionNumber
				--,traClr.strTransferStorageTicket
				,(ISNULL(glTRA.dblTotal,0)) AS dblClearingTotal
				,dblCredit
				,dblDebit
			FROM vyuGRTransferClearing traClr
			CROSS APPLY tblSMStartingNumber pfxTRA
			CROSS APPLY tblSMStartingNumber pfxRct
			OUTER APPLY (
				select 			
					gd.strTransactionId
					,[dblTotal]  = ((isnull(gd.dblCredit, 0) - isnull(gd.dblDebit, 0)) * case when gd.strCode = 'TRC' then -1 else 1 end )
					,gd.dblCredit
					,gd.dblDebit
				from 
					tblGLDetail gd
				INNER JOIN vyuGLAccountDetail acnt ON gd.intAccountId = acnt.intAccountId
				where
					gd.strTransactionId = traClr.strTransactionNumber
				and gd.ysnIsUnposted = 0 
				and acnt.intAccountCategoryId = 45
				and gd.ysnIsUnposted = 0 
		
			) glTRA
			WHERE 
				pfxTRA.intStartingNumberId = 72
			AND pfxRct.intStartingNumberId = 23
			AND traClr.strTransferStorageTicket LIKE pfxTRA.strPrefix + '%'
			AND traClr.strTransactionNumber LIKE pfxRct.strPrefix + '%'			
			AND traClr.strMark <> '2.3'
			--AND traClr.strTransferStorageTicket = 'TRA-520'
			and ( traClr.strTransferStorageTicket = @TransferTransaction)
			--GROUP BY traClr.strTransferStorageTicket
			UNION ALL
			--TRA
			SELECT DISTINCT 
				'3.2 GL IR TRA show all'
				,traClr.strTransactionNumber
				--,traClr.strTransferStorageTicket
				,ISNULL(glTRA.dblTotal,0) AS dblClearingTotal
				,dblCredit
				,dblDebit
			FROM vyuGRTransferClearing traClr
			CROSS APPLY tblSMStartingNumber pfxTRA
			OUTER APPLY (
				select 			
					gd.strTransactionId
					,[dblTotal]  = (isnull(gd.dblCredit, 0) - isnull(gd.dblDebit, 0)) * case when gd.strCode = 'TRC' then -1 else 1 end 
					,dblCredit
					,dblDebit
				from 
					tblGLDetail gd
				INNER JOIN vyuGLAccountDetail acnt ON gd.intAccountId = acnt.intAccountId
				where
					gd.strTransactionId = traClr.strTransactionNumber
				and gd.ysnIsUnposted = 0 
				and acnt.intAccountCategoryId = 45
				and gd.ysnIsUnposted = 0 
		
			) glTRA
			WHERE 
				pfxTRA.intStartingNumberId = 72
			AND traClr.strTransactionNumber LIKE pfxTRA.strPrefix + '%'
			AND glTRA.dblTotal <> 0
			and ( traClr.strTransactionNumber = @TransferTransaction)			
			AND traClr.strMark <> '2.3'

			
			--select * from vyuGRTransferClearing where strTransferStorageTicket = @TransferTransaction
		end

		----

		--RECEIPT TOTAL
		SELECT
			--'4 Receipt Total'
			@Total_4 = SUM(dblTotal)-- AS dblClearingTotal
			--*
		FROM 		
			(
				select dblTotal from 
				
					(
					SELECT DISTINCT 
							tmptraClr.strTransferStorageTicket,
							CASE 
							WHEN tmptraClr.strTransactionNumber LIKE pfxRct.strPrefix + '%' 
							THEN tmptraClr.strTransferStorageTicket 
							ELSE tmptraClr.strTransactionNumber 
							END AS strTransactionNumber
						FROM vyuGRTransferClearing tmptraClr
						OUTER APPLY tblSMStartingNumber pfxRct
						WHERE
							pfxRct.intStartingNumberId = 23			
							AND tmptraClr.strMark <> '2.3'
					) traClr
					OUTER APPLY (
						select 			
							gd.strTransactionId
							,[dblTotal]  = sum(isnull(gd.dblDebit, 0) - isnull(gd.dblCredit, 0))
				
							--gd.*
						from 
							tblGLDetail gd
						INNER JOIN vyuGLAccountDetail acnt ON gd.intAccountId = acnt.intAccountId
						where
							gd.strTransactionId = traClr.strTransferStorageTicket
						and gd.ysnIsUnposted = 0 
						and acnt.intAccountCategoryId = 45
						and gd.ysnIsUnposted = 0 
						and (gd.strDescription like '%Item%' or (strTransactionId like 'BL%'))
						group by 
							gd.strTransactionId
					) glRct
					where traClr.strTransactionNumber = @TransferTransaction				

				union all
				-- Below are the excess transaction --Make sure to only use this for DP - OS Transaction
				select 
					(isnull(Debit.Value, 0) - isnull(Credit.Value, 0)) as [dblTotal]				
				from 
					(select 
							sum ( ( dblQty  * ( (ABS(Total_Units_IR.dblTotalUnits) - abs(Total_Units_Transfer.dblTotalUnits)) / Total_Units_IR.dblTotalUnits)) * dblCost) as dblTotal --need to know the offsetting
						--,strTransactionId
					from tblICInventoryTransaction 
						outer apply (
							select sum(dblQty) as dblTotalUnits
							from tblICInventoryTransaction 
							where intTransactionId in ( select distinct intInventoryReceiptId 
									from vyuGRTransferClearing 
										where strTransferStorageTicket = @TransferTransaction
								and strTransactionNumber like 'IR-%' )

							and intTransactionTypeId = 4 

						)Total_Units_IR
						outer apply (
							select sum(dblQty) as dblTotalUnits
								from tblICInventoryTransaction 
									where intTransactionId = (
										select top 1 intTransferStorageId 
											from tblGRTransferStorage 
												where strTransferStorageTicket = @TransferTransaction
									)
										and intTransactionTypeId = 56 

						)Total_Units_Transfer
							where intTransactionId in ( select distinct intInventoryReceiptId 
									from vyuGRTransferClearing 
										where strTransferStorageTicket = @TransferTransaction
								and strTransactionNumber like 'IR-%' )

							and intTransactionTypeId = 4 
						--group by strTransactionId
					) Data_Value

					CROSS APPLY dbo.fnGetDebit(Data_Value.dblTotal) Debit
					CROSS APPLY dbo.fnGetCredit(Data_Value.dblTotal) Credit
					Cross Apply (select * from fnGRWhatIsMyTransfer(@TransferTransaction, null)) KindOfTransaction
					where KindOfTransaction.DP_TO_OS = 1



				union all
				-- Below are the excess transaction --Make sure to only use this for DP - OS Transaction
				--Cost Adjustment
				select 
					(isnull(Debit.Value, 0) - isnull(Credit.Value, 0)) as [dblTotal]				
				from 
					(select 
							sum ( ( dblQty  * ( (ABS(Total_Units_IR.dblTotalUnits) - abs(Total_Units_Transfer.dblTotalUnits)) / Total_Units_IR.dblTotalUnits)) * 
											
							( abs( dblCost - TransferCost.dblTransferCost ) * case when TransferCost.dblTransferCost > dblCost then 1 else -1 end )
						
						
							) as dblTotal --need to know the offsetting
						--,strTransactionId
					from tblICInventoryTransaction 
						outer apply (
							select sum(dblQty) as dblTotalUnits
							from tblICInventoryTransaction 
							where intTransactionId in ( select distinct intInventoryReceiptId 
									from vyuGRTransferClearing 
										where strTransferStorageTicket = @TransferTransaction
								and strTransactionNumber like 'IR-%' )

							and intTransactionTypeId = 4 

						)Total_Units_IR
						outer apply (
							select sum(dblQty) as dblTotalUnits
								from tblICInventoryTransaction 
									where intTransactionId = (
										select top 1 intTransferStorageId 
											from tblGRTransferStorage 
												where strTransferStorageTicket = @TransferTransaction
									)
										and intTransactionTypeId = 56 

						)Total_Units_Transfer

						outer apply (
							select top 1 dblCost as dblTransferCost
							from tblICInventoryTransaction TransferCost
								where TransferCost.strTransactionId = @TransferTransaction
									and TransferCost.intTransactionTypeId = 56
						) TransferCost
						where intTransactionId in ( select distinct intInventoryReceiptId 
								from vyuGRTransferClearing 
									where strTransferStorageTicket = @TransferTransaction
								and strTransactionNumber like 'IR-%' )

						and intTransactionTypeId = 4 
						--group by strTransactionId
					) Data_Value

					CROSS APPLY dbo.fnGetDebit(Data_Value.dblTotal) Debit
					CROSS APPLY dbo.fnGetCredit(Data_Value.dblTotal) Credit
					Cross Apply (select * from fnGRWhatIsMyTransfer(@TransferTransaction, null)) KindOfTransaction
					where KindOfTransaction.DP_TO_OS = 1
		) A
		
		
		

	
		if @ShowAll = 1
			SELECT
				'4 Receipt Total show all'
				,(dblTotal) AS dblClearingTotal
				,dblDebit
				,dblCredit
				,strDescription
				,strTransactionId
				--*
			FROM (
				SELECT DISTINCT 
					tmptraClr.strTransferStorageTicket,
					CASE 
					WHEN tmptraClr.strTransactionNumber LIKE pfxRct.strPrefix + '%' 
					THEN tmptraClr.strTransferStorageTicket 
					ELSE tmptraClr.strTransactionNumber 
					END AS strTransactionNumber
				FROM vyuGRTransferClearing tmptraClr
				OUTER APPLY tblSMStartingNumber pfxRct
				WHERE
					pfxRct.intStartingNumberId = 23	
					AND tmptraClr.strMark <> '2.3'
			) traClr
			OUTER APPLY (
				select 			
					gd.strTransactionId
					,[dblTotal]  = (isnull(gd.dblDebit, 0) - isnull(gd.dblCredit, 0))
					,dblDebit
					,dblCredit
					,gd.strDescription
					--gd.*
				from 
					tblGLDetail gd
				INNER JOIN vyuGLAccountDetail acnt ON gd.intAccountId = acnt.intAccountId
				where
					gd.strTransactionId = traClr.strTransferStorageTicket
				and gd.ysnIsUnposted = 0 
				and acnt.intAccountCategoryId = 45
				and gd.ysnIsUnposted = 0 
				--and gd.strDescription like '%Item%'
		
			) glRct
			WHERE 
			traClr.strTransactionNumber = @TransferTransaction
			and (glRct.strDescription like '%Item%' or (strTransactionId like 'BL%'))	
			

			union all
			-- Below are the excess transaction --Make sure to only use this for DP - OS Transaction
			select 
				'4 Excess Receipt Total show all'
				,(isnull(Debit.Value, 0) - isnull(Credit.Value, 0)) as [dblTotal]
				, Debit.Value as dblDebit
				,Credit.Value as dblCredit			
				,'These are the excess' strDescription
				,@TransferTransaction as strTransactionId
			from 
				(select 
						sum ( ( dblQty  * ( (ABS(Total_Units_IR.dblTotalUnits) - abs(Total_Units_Transfer.dblTotalUnits)) / Total_Units_IR.dblTotalUnits)) * dblCost) as dblTotal --need to know the offsetting
					--,strTransactionId
				from tblICInventoryTransaction 
					outer apply (
						select sum(dblQty) as dblTotalUnits
						from tblICInventoryTransaction 
						where intTransactionId in ( select distinct intInventoryReceiptId 
								from vyuGRTransferClearing 
									where strTransferStorageTicket = @TransferTransaction
								and strTransactionNumber like 'IR-%' )

						and intTransactionTypeId = 4 

					)Total_Units_IR
					outer apply (
						select sum(dblQty) as dblTotalUnits
							from tblICInventoryTransaction 
								where intTransactionId = (
									select top 1 intTransferStorageId 
										from tblGRTransferStorage 
											where strTransferStorageTicket = @TransferTransaction
								)
									and intTransactionTypeId = 56 

					)Total_Units_Transfer
						where intTransactionId in ( select distinct intInventoryReceiptId 
								from vyuGRTransferClearing 
									where strTransferStorageTicket = @TransferTransaction
								and strTransactionNumber like 'IR-%' )

						and intTransactionTypeId = 4 
					--group by strTransactionId
				) Data_Value

				CROSS APPLY dbo.fnGetDebit(Data_Value.dblTotal) Debit
				CROSS APPLY dbo.fnGetCredit(Data_Value.dblTotal) Credit
				Cross Apply (select * from fnGRWhatIsMyTransfer(@TransferTransaction, null)) KindOfTransaction
				where KindOfTransaction.DP_TO_OS = 1


			union all
			-- Below are the excess transaction --Make sure to only use this for DP - OS Transaction
			--Cost Adjustment
			select 
				'4 Excess Cost Adjustment Receipt Total show all'
				,(isnull(Debit.Value, 0) - isnull(Credit.Value, 0)) as [dblTotal]
				, Debit.Value as dblDebit
				,Credit.Value as dblCredit			
				,'These are the excess cost adjustment' strDescription
				,@TransferTransaction as strTransactionId
			from 
				(select 
						sum ( ( dblQty  * ( (ABS(Total_Units_IR.dblTotalUnits) - abs(Total_Units_Transfer.dblTotalUnits)) / Total_Units_IR.dblTotalUnits)) * 
											
						( abs( dblCost - TransferCost.dblTransferCost ) * case when TransferCost.dblTransferCost > dblCost then 1 else -1 end )
						
						
						) as dblTotal --need to know the offsetting
					--,strTransactionId
				from tblICInventoryTransaction 
					outer apply (
						select sum(dblQty) as dblTotalUnits
						from tblICInventoryTransaction 
						where intTransactionId in ( select distinct intInventoryReceiptId 
								from vyuGRTransferClearing 
									where strTransferStorageTicket = @TransferTransaction 
								and strTransactionNumber like 'IR-%')

						and intTransactionTypeId = 4 

					)Total_Units_IR
					outer apply (
						select sum(dblQty) as dblTotalUnits
							from tblICInventoryTransaction 
								where intTransactionId = (
									select top 1 intTransferStorageId 
										from tblGRTransferStorage 
											where strTransferStorageTicket = @TransferTransaction
								)
									and intTransactionTypeId = 56 

					)Total_Units_Transfer

					outer apply (
						select top 1 dblCost as dblTransferCost
						from tblICInventoryTransaction TransferCost
							where TransferCost.strTransactionId = @TransferTransaction
								and TransferCost.intTransactionTypeId = 56
					) TransferCost
					where intTransactionId in ( select distinct intInventoryReceiptId 
							from vyuGRTransferClearing 
								where strTransferStorageTicket = @TransferTransaction
								and strTransactionNumber like 'IR-%' )

					and intTransactionTypeId = 4 
					--group by strTransactionId
				) Data_Value

				CROSS APPLY dbo.fnGetDebit(Data_Value.dblTotal) Debit
				CROSS APPLY dbo.fnGetCredit(Data_Value.dblTotal) Credit
				Cross Apply (select * from fnGRWhatIsMyTransfer(@TransferTransaction, null)) KindOfTransaction
				where KindOfTransaction.DP_TO_OS = 1



	end

	set @Total_1 = isnull(@Total_1, 0)
	set @Total_2 = isnull(@Total_2, 0)
	set @Total_3 = isnull(@Total_3, 0)
	set @Total_3_2 = isnull(@Total_3_2, 0)
	set @Total_4 = isnull(@Total_4, 0)
	--select 'Computational'

	select @TransferTransaction as Text1, '0' as value1
			, '' as Text2, '0'as value2
			, '' as compuation
			, '0' as total 
	union 
	select '1 Transfer' as Text1, @Total_1 as value1
			, '2 Receipt' as Text2, @Total_2 as value2
			, '1-2 Computation' as compuation
			, @Total_1 - @Total_2 as total 
	union
	select '3.1 GL IR TRA' as Text1, @Total_3 as value1
			--,'3.2 GL IR TRA', @Total_3_2
			,'4 Receipt Total' as Text2, @Total_4 as value2
			,'3-4 Computation' as compuation, (@Total_3 + @Total_3_2) - @Total_4 as total 
	

	if @MoreInfo = 1
	begin

		select @TransferTransaction, sum(dblCredit) , sum(dblDebit) 
			from tblGLDetail 
				where strTransactionId in 
					(select strTransactionNumber 
						from vyuGRTransferClearing 
							where strTransferStorageTicket = @TransferTransaction) 
					and strDescription like '%CLEARING%DI-INSPECTION%'


		select distinct strTransactionId
			from tblGLDetail 
				where strTransactionId in 
					(select strTransactionNumber 
						from vyuGRTransferClearing 
							where strTransferStorageTicket = @TransferTransaction) 
					and strDescription like '%CLEARING%DI-INSPECTION%'
		select * from dbo.fnGRWhatIsMyTransfer(@TransferTransaction, null)

	end
	
-- End Dissection


	

end
