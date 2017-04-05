declare @build_m int
set @build_m = 0

if EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblSMBuildNumber' and [COLUMN_NAME] = 'strVersionNo')
BEGIN

	exec sp_executesql N'select @build_m = intVersionID from tblSMBuildNumber where strVersionNo like ''%16.1%'' '  , 
		N'@build_m int output', @build_m output;
END


if @build_m = 0

BEGIN

	PRINT '*** Start entity schema update ***'
	IF  EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblEMEntity') 
		AND EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblEMEntityContact') 
		AND EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblEMEntityLocation') 
		AND EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblEMEntityToContact') 
	
	BEGIN
		IF NOT EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblEMEntity' AND [COLUMN_NAME] = 'strContactNumber') 
		BEGIN
			PRINT 'DROPPING CONSTRAINT RELATED TO tblEMEntity'

			declare @constraint varchar(500)
			set @constraint = ''
			select @constraint = name from sys.foreign_keys WHERE  OBJECT_NAME(parent_object_id) = 'tblAPVendor' and OBJECT_NAME(referenced_object_id) = 'tblEMEntityContact' 
		
			if(@constraint <> '')
				exec('ALTER TABLE tblAPVendor DROP CONSTRAINT [' + @constraint +']' )

			set @constraint = ''
			select @constraint = name from sys.foreign_keys WHERE  OBJECT_NAME(parent_object_id) = 'tblAPVendorToContact' and OBJECT_NAME(referenced_object_id) = 'tblAPVendor' 
			if(@constraint <> '')
				exec('ALTER TABLE tblAPVendorToContact DROP CONSTRAINT [' + @constraint +']' )
	
			set @constraint = ''
			select @constraint = name from sys.foreign_keys WHERE  OBJECT_NAME(parent_object_id) = 'tblAPBill' and OBJECT_NAME(referenced_object_id) = 'tblAPVendor' 
			if(@constraint <> '')
				exec('ALTER TABLE tblAPBill DROP CONSTRAINT [' + @constraint +']' )
	
	
			set @constraint = ''
			select @constraint = name from sys.foreign_keys WHERE  OBJECT_NAME(parent_object_id) = 'tblICCategoryVendor' and OBJECT_NAME(referenced_object_id) = 'tblAPVendor' 
			if(@constraint <> '')
				exec('ALTER TABLE tblICCategoryVendor DROP CONSTRAINT [' + @constraint +']' )

			set @constraint = ''
			select @constraint = name from sys.foreign_keys WHERE  OBJECT_NAME(parent_object_id) = 'tblHDTicket' and OBJECT_NAME(referenced_object_id) = 'tblARCustomer' 
			if(@constraint <> '')
				exec('ALTER TABLE tblHDTicket DROP CONSTRAINT [' + @constraint +']' )

			/*Add by Jayson for tblHDProject*/
			set @constraint = ''
			select @constraint = name from sys.foreign_keys WHERE  OBJECT_NAME(parent_object_id) = 'tblHDProject' and OBJECT_NAME(referenced_object_id) = 'tblARCustomer' 
			if(@constraint <> '')
				exec('ALTER TABLE tblHDProject DROP CONSTRAINT [' + @constraint +']' )
		
			set @constraint = ''
			select @constraint = name from sys.foreign_keys WHERE OBJECT_NAME(parent_object_id) = 'tblHDProject' and OBJECT_NAME(referenced_object_id) = 'tblEMEntityContact' and name = 'FK_Project_Contact'
			if(@constraint <> '')
				exec('ALTER TABLE tblHDProject DROP CONSTRAINT [' + @constraint +']' )
		
			set @constraint = ''
			select @constraint = name from sys.foreign_keys WHERE OBJECT_NAME(parent_object_id) = 'tblHDProject' and OBJECT_NAME(referenced_object_id) = 'tblEMEntityContact' and name = 'FK_Project_CusProjMgr'
			if(@constraint <> '')
				exec('ALTER TABLE tblHDProject DROP CONSTRAINT [' + @constraint +']' )
		
			set @constraint = ''
			select @constraint = name from sys.foreign_keys WHERE OBJECT_NAME(parent_object_id) = 'tblHDProject' and OBJECT_NAME(referenced_object_id) = 'tblEMEntityContact' and name = 'FK_Project_CusLeadSponsor'
			if(@constraint <> '')
				exec('ALTER TABLE tblHDProject DROP CONSTRAINT [' + @constraint +']' )
		
			set @constraint = ''
			select @constraint = name from sys.foreign_keys WHERE OBJECT_NAME(parent_object_id) = 'tblHDProjectModule' and OBJECT_NAME(referenced_object_id) = 'tblEMEntityContact'
			if(@constraint <> '')
				exec('ALTER TABLE tblHDProjectModule DROP CONSTRAINT [' + @constraint +']' )
	
			set @constraint = ''
			select @constraint = name from sys.foreign_keys WHERE  OBJECT_NAME(parent_object_id) = 'tblARCustomerToContact' and OBJECT_NAME(referenced_object_id) = 'tblARCustomer' 
			if(@constraint <> '')
				exec('ALTER TABLE tblARCustomerToContact DROP CONSTRAINT [' + @constraint +']' )
	
			set @constraint = ''
			select @constraint = name from sys.foreign_keys WHERE  OBJECT_NAME(parent_object_id) = 'tblAPVendorToContact' and OBJECT_NAME(referenced_object_id) = 'tblEMEntityContact' 
			if(@constraint <> '')
				exec('ALTER TABLE tblAPVendorToContact DROP CONSTRAINT [' + @constraint +']' )
	
			set @constraint = ''
			select @constraint = name from sys.foreign_keys WHERE  OBJECT_NAME(parent_object_id) = 'tblARCustomerToContact' and OBJECT_NAME(referenced_object_id) = 'tblEMEntityContact' 
			if(@constraint <> '')
				exec('ALTER TABLE tblARCustomerToContact DROP CONSTRAINT [' + @constraint +']' )
		
			set @constraint = ''
			select @constraint = name from sys.foreign_keys WHERE  OBJECT_NAME(parent_object_id) = 'tblMFRecipe' and OBJECT_NAME(referenced_object_id) = 'tblARCustomer'
			if(@constraint <> '')
				exec('ALTER TABLE tblMFRecipe DROP CONSTRAINT [' + @constraint +']' )

			set @constraint = ''
			select @constraint = name from sys.foreign_keys WHERE  OBJECT_NAME(parent_object_id) = 'tblPOPurchase' and OBJECT_NAME(referenced_object_id) = 'tblAPVendor'
			if(@constraint <> '')
				exec('ALTER TABLE tblPOPurchase DROP CONSTRAINT [' + @constraint +']' )

			set @constraint = ''
			select @constraint = name from sys.foreign_keys WHERE  OBJECT_NAME(parent_object_id) = 'tblICInventoryReceipt' and OBJECT_NAME(referenced_object_id) = 'tblAPVendor'
			if(@constraint <> '')
				exec('ALTER TABLE tblICInventoryReceipt DROP CONSTRAINT [' + @constraint +']' )


			set @constraint = ''
			select @constraint = name from sys.foreign_keys WHERE  OBJECT_NAME(parent_object_id) = 'tblICInventoryReceipt' and OBJECT_NAME(referenced_object_id) = 'tblAPVendor'

			 if(@constraint <> '')
			  exec('ALTER TABLE tblICInventoryReceipt DROP CONSTRAINT [' + @constraint +']' )


			set @constraint = ''
			select @constraint = name from sys.foreign_keys WHERE  OBJECT_NAME(parent_object_id) = 'tblICItemLocation' and OBJECT_NAME(referenced_object_id) = 'tblAPVendor'

			 if(@constraint <> '')
			  exec('ALTER TABLE tblICItemLocation DROP CONSTRAINT [' + @constraint +']' )

			set @constraint = ''
			select @constraint = name from sys.foreign_keys WHERE  OBJECT_NAME(parent_object_id) = 'tblARCustomer' and OBJECT_NAME(referenced_object_id) = 'tblARSalesperson'
			if(@constraint <> '')
				exec('ALTER TABLE tblARCustomer DROP CONSTRAINT [' + @constraint +']' )

			set @constraint = ''
			select @constraint = name from sys.foreign_keys WHERE  OBJECT_NAME(parent_object_id) = 'tblARInvoice' and OBJECT_NAME(referenced_object_id) = 'tblARCustomer'
			if(@constraint <> '')
				exec('ALTER TABLE tblARInvoice DROP CONSTRAINT [' + @constraint +']' )	

			set @constraint = ''
			select @constraint = name from sys.foreign_keys WHERE  OBJECT_NAME(parent_object_id) = 'tblSOSalesOrder' and OBJECT_NAME(referenced_object_id) = 'tblARCustomer'
			if(@constraint <> '')
				exec('ALTER TABLE tblSOSalesOrder DROP CONSTRAINT [' + @constraint +']' )	

			set @constraint = ''
			select @constraint = name from sys.foreign_keys WHERE  OBJECT_NAME(parent_object_id) = 'tblARPayment' and OBJECT_NAME(referenced_object_id) = 'tblARCustomer'
			if(@constraint <> '')
				exec('ALTER TABLE tblARPayment DROP CONSTRAINT [' + @constraint +']' )	

			set @constraint = ''
			select @constraint = name from sys.foreign_keys WHERE  OBJECT_NAME(parent_object_id) = 'tblAPPayment' and OBJECT_NAME(referenced_object_id) = 'tblAPVendor'
			if(@constraint <> '')
				exec('ALTER TABLE tblAPPayment DROP CONSTRAINT [' + @constraint +']' )
	
	
			set @constraint = ''
			select @constraint = name from sys.foreign_keys WHERE  OBJECT_NAME(parent_object_id) = 'tblARCustomerProductVersion' and OBJECT_NAME(referenced_object_id) = 'tblARCustomer' 
			if(@constraint <> '')
				exec('ALTER TABLE tblARCustomerProductVersion DROP CONSTRAINT [' + @constraint +']' )
	
			set @constraint = ''
			select @constraint = name from sys.foreign_keys WHERE  OBJECT_NAME(parent_object_id) = 'tblCTContractHeader' and OBJECT_NAME(referenced_object_id) = 'tblARSalesperson'
			if(@constraint <> '')
				exec('ALTER TABLE tblCTContractHeader DROP CONSTRAINT [' + @constraint +']' )


			print 'Adding tblEMEntityContact columns to tblEMEntity'
			exec(N'	
			alter table tblEMEntity
			add [strContactNumber] [nvarchar](20) NOT NULL Default('''')

			alter table tblEMEntity
			add [strTitle] [nvarchar](35) NULL

			alter table tblEMEntity
			add [strDepartment] [nvarchar](30) NULL
		
			alter table tblEMEntity
			add [strMobile] [nvarchar](25) NULL

			alter table tblEMEntity
			add [strPhone] [nvarchar](25) NULL

			alter table tblEMEntity
			add [strPhone2] [nvarchar](25) NULL

			alter table tblEMEntity
			add [strEmail2] [nvarchar](75) NULL

			alter table tblEMEntity
			add [strFax] [nvarchar](25) NULL
		
			alter table tblEMEntity
			add [strNotes] [nvarchar](max) NULL
		
			alter table tblEMEntity
			add [strContactMethod] [nvarchar](20) NULL

			alter table tblEMEntity
			add [strTimezone] [nvarchar](100) NULL

			alter table tblEMEntity
			add [strEntityNo] [nvarchar](100) NULL
		
			alter table tblEMEntity
			add [ysnActive] [bit] NOT NULL DEFAULT ((1))


			alter table tblEMEntity
			add [intDefaultLocationId]       INT            NULL ')

			print 'Update tblEMEntity strEntityNo to get the Vendor strVendorId'
			IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblEMEntity' AND [COLUMN_NAME] = 'strEntityNo') 
			BEGIN
				exec(N' update a set a.strEntityNo = b.strVendorId
						from tblEMEntity a
							join tblAPVendor b
								on a.intEntityId =  b.intEntityId ')
			END

			print 'Update tblEMEntity strEntityNo to get the tblARCustomer strCustomerNumber'
			IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblEMEntity' AND [COLUMN_NAME] = 'strEntityNo') 
			BEGIN
				exec(N' update a set a.strEntityNo = b.strCustomerNumber
						from tblEMEntity a
							join tblARCustomer b
								on a.intEntityId =  b.intEntityId ')
			END

			print 'Update tblEMEntity strEntityNo to get the tblARSalesperson strSalespersonId'
			IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblEMEntity' AND [COLUMN_NAME] = 'strEntityNo') 
			BEGIN
				exec(N' update a set a.strEntityNo = b.strSalespersonId
						from tblEMEntity a
							join tblARSalesperson b
								on a.intEntityId =  b.intEntityId ')
			END


			print 'Moving Default Location'
			exec(N'				
					update a set a.intDefaultLocationId = b.intDefaultLocationId from tblEMEntity  a
						join tblAPVendor b
							on a.intEntityId = b.intEntityId				
					
					update a set a.intDefaultLocationId=b.intDefaultLocationId from tblEMEntity  a
						join tblARCustomer b
							on a.intEntityId = b.intEntityId
				')
	
			print 'check if the ysnActive is available in tblEMEntityContact'
			 IF NOT EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblEMEntityContact' AND [COLUMN_NAME] = 'ysnActive') 
			 BEGIN
			  exec(N'alter table tblEMEntityContact 
				add [ysnActive] [bit] NOT NULL DEFAULT ((1))')
			 END

			print 'Moving Entity Contact Data to Entity'
			IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblEMEntityContact' AND [COLUMN_NAME] = 'strContactNumber') 
		BEGIN
			exec(N'	
					update a set
							a.strContactNumber = b.strContactNumber							
						from tblEMEntity a
							join tblEMEntityContact b
								on a.intEntityId = b.intEntityId')
		END

		IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblEMEntityContact' AND [COLUMN_NAME] = 'strTitle') 
		BEGIN
			exec(N'	
					update a set
							a.strTitle = b.strTitle							
						from tblEMEntity a
							join tblEMEntityContact b
								on a.intEntityId = b.intEntityId')
		END

		IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblEMEntityContact' AND [COLUMN_NAME] = 'strDepartment') 
		BEGIN
			exec(N'	
					update a set
							a.strDepartment = b.strDepartment							
						from tblEMEntity a
							join tblEMEntityContact b
								on a.intEntityId = b.intEntityId')
		END

		IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblEMEntityContact' AND [COLUMN_NAME] = 'strMobile') 
		BEGIN
			exec(N'	
					update a set
							a.strMobile = b.strMobile							
						from tblEMEntity a
							join tblEMEntityContact b
								on a.intEntityId = b.intEntityId')
		END

		IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblEMEntityContact' AND [COLUMN_NAME] = 'strPhone') 
		BEGIN
			exec(N'	
					update a set
							a.strPhone = b.strPhone							
						from tblEMEntity a
							join tblEMEntityContact b
								on a.intEntityId = b.intEntityId')
		END

		IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblEMEntityContact' AND [COLUMN_NAME] = 'strPhone2') 
		BEGIN
			exec(N'	
					update a set
							a.strPhone2 = b.strPhone2							
						from tblEMEntity a
							join tblEMEntityContact b
								on a.intEntityId = b.intEntityId')
		END

		IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblEMEntityContact' AND [COLUMN_NAME] = 'strEmail2') 
		BEGIN
			exec(N'	
					update a set
							a.strEmail2 = b.strEmail2							
						from tblEMEntity a
							join tblEMEntityContact b
								on a.intEntityId = b.intEntityId')
		END

		IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblEMEntityContact' AND [COLUMN_NAME] = 'strFax') 
		BEGIN
			exec(N'	
					update a set
							a.strFax = b.strFax							
						from tblEMEntity a
							join tblEMEntityContact b
								on a.intEntityId = b.intEntityId')
		END

		IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblEMEntityContact' AND [COLUMN_NAME] = 'strNotes') 
		BEGIN
			exec(N'	
					update a set
							a.strNotes = b.strNotes							
						from tblEMEntity a
							join tblEMEntityContact b
								on a.intEntityId = b.intEntityId')
		END

		IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblEMEntityContact' AND [COLUMN_NAME] = 'strContactMethod') 
		BEGIN
			exec(N'	
					update a set
							a.strContactMethod = b.strContactMethod							
						from tblEMEntity a
							join tblEMEntityContact b
								on a.intEntityId = b.intEntityId')
		END

		IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblEMEntityContact' AND [COLUMN_NAME] = 'strTimezone') 
		BEGIN
			exec(N'	
					update a set
							a.strTimezone = b.strTimezone							
						from tblEMEntity a
							join tblEMEntityContact b
								on a.intEntityId = b.intEntityId')
		END

		IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblEMEntityContact' AND [COLUMN_NAME] = 'ysnActive') 
		BEGIN
			exec(N'	
					update a set
							a.ysnActive = b.ysnActive							
						from tblEMEntity a
							join tblEMEntityContact b
								on a.intEntityId = b.intEntityId')
		END



	
	
	
			IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblAPVendorToContact') 
			BEGIN	

				print 'Adding Default Contact to Vendor To Contact'	
				exec(N'	ALTER TABLE tblAPVendorToContact
					add ysnDefaultContact bit')

				print 'Adding user type to Vendor To Contact'
				exec(N' ALTER TABLE tblAPVendorToContact
						add strUserType [nvarchar](20) NOT NULL Default('''')')
			END
	

			print 'Fix Vendor BadData '
			IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblAPVendorToContact') 
			BEGIN
				exec(N'UPDATE A SET A.intDefaultContactId = B.intContactId
						FROM tblAPVendor A
							JOIN tblAPVendorToContact B
								on A.intVendorId = B.intVendorId 
							where A.intDefaultContactId <> B.intContactId
						')
			END

		
			print 'Update vendor to contact default contact column'
			IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblAPVendorToContact' AND [COLUMN_NAME] = 'ysnDefaultContact') 
			BEGIN
				print 'Updating vendor to contact default contact column'
				exec(N' update b set b.ysnDefaultContact = 1 
							from tblAPVendor a
								join tblAPVendorToContact b
									on a.intDefaultContactId = b.intContactId ')
			END

			print 'Moving linking to entity id instead of vendor id'
			IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblAPVendorToContact' AND [COLUMN_NAME] = 'intVendorId') 
			BEGIN
				exec(N'	
						update a set a.intVendorId = b.intEntityId
							from tblAPVendorToContact a
								join tblAPVendor b
									on a.intVendorId = b.intVendorId')
			END


			print 'Update Linking of tblAPBill from vendor id to entity id'
			IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblAPBill' AND [COLUMN_NAME] = 'intVendorId') 
			BEGIN
				exec(N' update a set a.intVendorId = b.intEntityId
						from tblAPBill a
							join tblAPVendor b
								on a.intVendorId =  b.intVendorId ')
			END


			print 'Update Linking of tblICCategoryVendor from vendor id to entity id'
			IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblICCategoryVendor' AND [COLUMN_NAME] = 'intVendorId') 
			BEGIN
				exec(N' update a set a.intVendorId = b.intEntityId
						from tblICCategoryVendor a
							join tblAPVendor b
								on a.intVendorId =  b.intVendorId ')
			END
	
			
			print 'Update Linking of tblHDTicket from customer id to entity id'
			IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblHDTicket' AND [COLUMN_NAME] = 'intCustomerId') 
			BEGIN
				exec(N' UPDATE a set a.intCustomerId = b.intEntityId
							from tblHDTicket a 
								join tblARCustomer b 
									on a.intCustomerId = b.intCustomerId')
			END
			
			print 'Update Linking of tblARInvoice from customer id to entity id'
			IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblARInvoice' AND [COLUMN_NAME] = 'intCustomerId') 
			BEGIN
				exec(N'
						UPDATE a set a.intCustomerId = b.intEntityId
							from tblARInvoice a 
								join tblARCustomer b 
									on a.intCustomerId = b.intCustomerId')						
			END
		
			print 'Update Linking of tblCCSite from customer id to entity id'
			IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblCCSite' AND [COLUMN_NAME] = 'intCustomerId') 
			BEGIN
				exec(N'	UPDATE a set a.intCustomerId = b.intEntityId
						from tblCCSite a 
							join tblARCustomer b 
								on a.intCustomerId = b.intCustomerId')
			END

	
			print 'Update Linking of tblHDProject from customer id to entity id'
			IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblHDProject' AND [COLUMN_NAME] = 'intCustomerId') 
			BEGIN
				exec(N'
						UPDATE a set a.intCustomerId = b.intEntityId
							from tblHDProject a 
								join tblARCustomer b 
									on a.intCustomerId = b.intCustomerId')
			END
	
			print 'Update Linking of tblMFRecipe from customer id to entity id'
			IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblMFRecipe' AND [COLUMN_NAME] = 'intCustomerId') 
			BEGIN
				exec(N' UPDATE a set a.intCustomerId = b.intEntityId
						from tblMFRecipe a 
							join tblARCustomer b 
								on a.intCustomerId = b.intCustomerId')
			END
		
			print 'Update Linking of tblSOSalesOrder from customer id to entity id'
			IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblSOSalesOrder' AND [COLUMN_NAME] = 'intCustomerId') 
			BEGIN
				exec(N'
						UPDATE a set a.intCustomerId = b.intEntityId
							from tblSOSalesOrder a 
								join tblARCustomer b 
									on a.intCustomerId = b.intCustomerId')
			END

			print 'Update Linking of tblICItemCustomerXref from customer id to entity id'
			IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblICItemCustomerXref' AND [COLUMN_NAME] = 'intCustomerId') 
			BEGIN
				exec(N'
						UPDATE a set a.intCustomerId = b.intEntityId
							from tblICItemCustomerXref a 
								join tblARCustomer b 
									on a.intCustomerId = b.intCustomerId')
			END

			print 'Update Linking of tblARPayment from customer id to entity id'
			IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblARPayment' AND [COLUMN_NAME] = 'intCustomerId') 
			BEGIN
				exec(N'
						UPDATE a set a.intCustomerId = b.intEntityId
							from tblARPayment a 
								join tblARCustomer b 
									on a.intCustomerId = b.intCustomerId')
			END


			print 'Update Linking of tblARCustomerToContact from customer id to entity id'
			IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblARCustomerToContact' AND [COLUMN_NAME] = 'intCustomerId') 
			BEGIN
				exec(N'	UPDATE a set a.intCustomerId = b.intEntityId
							from tblARCustomerToContact a 
								join tblARCustomer b 
									on a.intCustomerId = b.intCustomerId')
			END

			print 'Add ysnDefault column to ARCustomerToContact'
			IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblARCustomerToContact') 
			BEGIN
				exec(N'	
					ALTER TABLE tblARCustomerToContact
					add ysnDefaultContact bit')
			END

	


			print 'Update ysnDefaultContact'
			IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblARCustomerToContact' AND [COLUMN_NAME] = 'ysnDefaultContact') 
			BEGIN
				exec(N'	update 
							b set b.ysnDefaultContact = 1 
						from tblARCustomer a
							join tblARCustomerToContact b
								on a.intDefaultContactId = b.intARCustomerToContactId	')
			END
		
			print 'Update Linking of tblICItemOwner from customer id to entity idt'
			IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblICItemOwner' AND [COLUMN_NAME] = 'intOwnerId') 
			BEGIN
				exec(N'
						UPDATE a set a.intOwnerId = b.intEntityId
							from tblICItemOwner a 
								join tblARCustomer b 
									on a.intOwnerId = b.intCustomerId')
			END	
		
			print 'Update Linking of tblHDProject from entity contact to entity id'
			IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblHDProject' AND [COLUMN_NAME] = 'intCustomerContactId') 
			BEGIN
				exec(N' UPDATE a set a.intCustomerContactId = b.intEntityId
				from tblHDProject a 
					join tblEMEntityContact b 
						on a.intCustomerContactId = b.intContactId')
			END

	
			print 'Update Linking of tblHDProject intCustomerLeadershipSponsor from entity contact to entity id'
			IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblHDProject' AND [COLUMN_NAME] = 'intCustomerLeadershipSponsor') 
			BEGIN
				exec(N'		
						UPDATE a set a.intCustomerLeadershipSponsor = b.intEntityId
							from tblHDProject a 
								join tblEMEntityContact b 
									on a.intCustomerLeadershipSponsor = b.intContactId')
			END
	
					
			print 'Update Linking of tblHDProject intCustomerProjectManager from entity contact to entity id'
			IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblHDProject' AND [COLUMN_NAME] = 'intCustomerProjectManager') 
			BEGIN
				exec(N'	
						UPDATE a set a.intCustomerProjectManager = b.intEntityId
							from tblHDProject a 
								join tblEMEntityContact b 
									on a.intCustomerProjectManager = b.intContactId	')
			END		
							
	
			print 'Update Linking of tblHDProjectModule from entity contact to entity id'
			IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblHDProjectModule' AND [COLUMN_NAME] = 'intContactId') 
			BEGIN
				exec(N'
						UPDATE a set a.intContactId = b.intEntityId
							from tblHDProjectModule a 
								join tblEMEntityContact b 
									on a.intContactId = b.intContactId	')
			END
	
			print 'Update Linking of tblAPVendor default contact from entity contact to entity id'
			IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblAPVendor' AND [COLUMN_NAME] = 'intDefaultContactId') 
			BEGIN

				IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblEMEntityContact' AND [COLUMN_NAME] = 'intContactId') 
				BEGIN
					exec(N'						
						UPDATE a set a.intDefaultContactId = b.intEntityId
							from tblAPVendor a 
								join tblEMEntityContact b 
									on a.intDefaultContactId = b.intContactId		')	
				END
				
			END

			print 'Update Linking of tblAPVendorToContact from entity contact to entity id'
			IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblAPVendorToContact' AND [COLUMN_NAME] = 'intContactId') 
			BEGIN
				exec(N'
						UPDATE a set a.intContactId = b.intEntityId
							from tblAPVendorToContact a 
								join tblEMEntityContact b 
									on a.intContactId = b.intContactId	')
			END

			print 'Update Linking of tblARCustomerToContact from entity contact to entity id'
			IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblARCustomerToContact' AND [COLUMN_NAME] = 'intContactId') 
			BEGIN
				exec(N'
						UPDATE a set a.intContactId = b.intEntityId
							from tblARCustomerToContact a 
								join tblEMEntityContact b 
									on a.intContactId = b.intContactId		')		
			END

			print 'Update Linking of tblARCustomer salesperson from salespersonid to entityid '
			IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblARCustomer' AND [COLUMN_NAME] = 'intSalespersonId') 
			BEGIN
				exec(N'		
						UPDATE a set a.intSalespersonId = b.intEntityId
							from tblARCustomer a 
								join tblARSalesperson b 
									on a.intSalespersonId = b.intSalespersonId	')
			END

			-- Create the new intEntityVendorId column in tblICInventoryReceipt
			IF	EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblICInventoryReceipt') 
				AND NOT EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblICInventoryReceipt' AND [COLUMN_NAME] = 'intEntityVendorId') 
			BEGIN 
				EXEC ('ALTER TABLE tblICInventoryReceipt ADD intEntityVendorId INT NULL')
			END

			print 'Update Linking of tblICInventoryReceipt intVendorId from intVendorId to entityid '
			IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblICInventoryReceipt' AND [COLUMN_NAME] = 'intVendorId') 
			BEGIN
		

			exec(N' UPDATE a set a.intEntityVendorId = b.intEntityId
						from tblICInventoryReceipt a 
							join tblAPVendor b 
							on a.intVendorId = b.intVendorId')
			END

			 print 'Update Linking of tblAPPayment intVendorId from intVendorId to entityid '
			 IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblAPPayment' AND [COLUMN_NAME] = 'intVendorId') 
			 BEGIN
				  exec(N' UPDATE a set a.intVendorId = b.intEntityId
							 from tblAPPayment a 
								  join tblAPVendor b 
									on a.intVendorId = b.intVendorId')
			END

			print 'Delete orphan entity to contact'
			IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblEMEntityToContact') 
			BEGIN

				exec(N'		
					delete from tblEMEntityToContact	where intEntityId not in ( select intEntityId from tblEMEntity)
			
					delete from tblEMEntityToContact	where intContactId not in ( select intEntityId from tblEMEntityContact)

					')


				print 'add locationid to tblEMEntityToContact'
				exec(N'		
						alter table tblEMEntityToContact
						add [intEntityLocationId]        INT NULL ')
			
				print 'Add strUserType tblEnttiyToContact'
				exec(N'		
						alter table tblEMEntityToContact
						add [strUserType]              NVARCHAR (5) COLLATE Latin1_General_CI_AS NULL ')
				print 'Add ysnPortalAccess to EntityToContact'
				exec(N'		
						alter table tblEMEntityToContact
						add [ysnPortalAccess]          BIT          NULL ')
				print 'Add ysnDefaultContact to EntityToContact'
				exec(N'					
						alter table tblEMEntityToContact
						add [ysnDefaultContact] BIT NOT NULL DEFAULT ((0))')

				print 'move tblARCustomerToContact to tblEMEntityToContact'
				IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblARCustomerToContact') 
				BEGIN
						exec(N'		
								INSERT INTO tblEMEntityToContact 
								(
								intEntityId
								,intContactId
								,intEntityLocationId
								,strUserType
								,ysnPortalAccess
								,ysnDefaultContact
								,intConcurrencyId
								)
								select 
								intCustomerId
								,intContactId
								,intEntityLocationId
								,strUserType
								,ysnPortalAccess
								,isnull(ysnDefaultContact,0)
								,intConcurrencyId
								from tblARCustomerToContact

							')
				END
		
				print 'move tblAPVendorToContact to tblEMEntityToContact'
				IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblAPVendorToContact') 
				BEGIN
					exec(N'		
						INSERT INTO tblEMEntityToContact 
						(
						intEntityId
						,intContactId
						,intEntityLocationId
						,strUserType
						,ysnPortalAccess
						,ysnDefaultContact
						,intConcurrencyId
						)
						select 
						intVendorId
						,intContactId
						,intEntityLocationId
						,strUserType
						,0
						,isnull(ysnDefaultContact,0)
						,intConcurrencyId
						from tblAPVendorToContact
						')
				END
		
			END
	
			IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblEMEntityType') 	
			BEGIN
				print 'Update entity type for customer '
				exec(N'		
						insert into tblEMEntityType(intEntityId,strType,intConcurrencyId)
						select b.intEntityId,''Customer'',0 from tblARCustomer a
							join tblEMEntity b
								on a.intEntityId = b.intEntityId
							where b.intEntityId not in (select intEntityId from tblEMEntityType)	')
	
				print 'Update entity type for Vendor'
				exec(N'		
						insert into tblEMEntityType(intEntityId,strType,intConcurrencyId)
						select b.intEntityId,''Vendor'',0 from tblAPVendor a
							join tblEMEntity b
								on a.intEntityId = b.intEntityId
							where b.intEntityId not in (select intEntityId from tblEMEntityType)	')

				print 'Update entity type for salesperson'
				exec(N'		
						insert into tblEMEntityType(intEntityId,strType,intConcurrencyId)
						select b.intEntityId,''Salesperson'',0 from tblARSalesperson a
							join tblEMEntity b
								on a.intEntityId = b.intEntityId
							where b.intEntityId not in (select intEntityId from tblEMEntityType)	')

				print 'Update entity type for User'
				IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblSMUserSecurity' AND [COLUMN_NAME] = 'intEntityId') 
				BEGIN
					exec(N'		
						insert into tblEMEntityType(intEntityId,strType,intConcurrencyId)		
						select b.intEntityId,''User'',0 from tblSMUserSecurity a
							join tblEMEntity b
								on a.intEntityId = b.intEntityId
							where b.intEntityId not in (select intEntityId from tblEMEntityType)	')
				END
		
			END
	

			print 'Update Linking of tblPOPurchase from vendor id to entity id'
			IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblPOPurchase' AND [COLUMN_NAME] = 'intVendorId') 
			BEGIN
				exec(N' update a set a.intVendorId = b.intEntityId
						from tblPOPurchase a
							join tblAPVendor b
								on a.intVendorId =  b.intVendorId ')
			END

			--print 'Update Linking of tblICInventoryReceipt from vendor id to entity id'
			--IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblICInventoryReceipt' AND [COLUMN_NAME] = 'intVendorId') 
			--BEGIN
			--	exec(N' update a set a.intVendorId = b.intEntityId
			--			from tblICInventoryReceipt a
			--				join tblAPVendor b
			--					on a.intVendorId =  b.intVendorId ')
			--END

			print 'Update Linking of tblICLot from vendor id to entity id'
			IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblICLot' AND [COLUMN_NAME] = 'intVendorId') 
			BEGIN
				exec(N' update a set a.intVendorId = b.intEntityId
						from tblICLot a
							join tblAPVendor b
								on a.intVendorId =  b.intVendorId ')
			END	

			print 'Update Linking of tblICItemLocation from vendor id to entity id'
			IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblICItemLocation' AND [COLUMN_NAME] = 'intVendorId') 
			BEGIN
				exec(N' update a set a.intVendorId = b.intEntityId
						from tblICItemLocation a
							join tblAPVendor b
								on a.intVendorId =  b.intVendorId ')
			END	
	
			print 'Update Linking of tblARCustomerProductVersion from customer id to entity id'
			IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblARCustomerProductVersion' AND [COLUMN_NAME] = 'intCustomerId') 
			BEGIN
				exec(N' update a set a.intCustomerId = b.intEntityId
						from tblARCustomerProductVersion a
							join tblARCustomer b
								on a.intCustomerId =  b.intCustomerId ')
			END			


			print 'Update Linking of tblCTContractHeader from salesperson id to entity id'
			IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblCTContractHeader' AND [COLUMN_NAME] = 'intSalespersonId') 
			BEGIN
				exec(N' update a set a.intSalespersonId = b.intEntityId
						from tblCTContractHeader a
							join tblARSalesperson b
								on a.intSalespersonId =  b.intSalespersonId ')
			END			

		END


			print 'Update tblEMEntityLocation to set the default Location'
			IF NOT EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblEMEntityLocation' AND [COLUMN_NAME] = 'ysnDefaultLocation') 
			BEGIN

				exec(N' alter table tblEMEntityLocation
					add [ysnDefaultLocation]       BIT            NULL')
				exec(N' update a set a.ysnDefaultLocation = 1
						from tblEMEntityLocation a
							join tblARCustomer b
								on b.intDefaultLocationId =  a.intEntityLocationId ')
				exec(N' update a set a.ysnDefaultLocation = 1
						from tblEMEntityLocation a
							join tblAPVendor b
								on b.intDefaultLocationId =  a.intEntityLocationId ')
			END
	END
	PRINT '*** End entity schema update ***'
END

GO