
IF NOT EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblEntity' AND [COLUMN_NAME] = 'strContactNumber') 
BEGIN
	PRINT 'DROPPING CONSTRAINT RELATED TO tblEntity'
	
	
	declare @constraint varchar(500)
	set @constraint = ''
	select @constraint = name from sys.foreign_keys WHERE  OBJECT_NAME(parent_object_id) = 'tblAPVendor' and OBJECT_NAME(referenced_object_id) = 'tblEntityContact' 
		
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
	select @constraint = name from sys.foreign_keys WHERE OBJECT_NAME(parent_object_id) = 'tblHDProject' and OBJECT_NAME(referenced_object_id) = 'tblEntityContact' and name = 'FK_Project_Contact'
	if(@constraint <> '')
		exec('ALTER TABLE tblHDProject DROP CONSTRAINT [' + @constraint +']' )
		
	set @constraint = ''
	select @constraint = name from sys.foreign_keys WHERE OBJECT_NAME(parent_object_id) = 'tblHDProject' and OBJECT_NAME(referenced_object_id) = 'tblEntityContact' and name = 'FK_Project_CusProjMgr'
	if(@constraint <> '')
		exec('ALTER TABLE tblHDProject DROP CONSTRAINT [' + @constraint +']' )
		
	set @constraint = ''
	select @constraint = name from sys.foreign_keys WHERE OBJECT_NAME(parent_object_id) = 'tblHDProject' and OBJECT_NAME(referenced_object_id) = 'tblEntityContact' and name = 'FK_Project_CusLeadSponsor'
	if(@constraint <> '')
		exec('ALTER TABLE tblHDProject DROP CONSTRAINT [' + @constraint +']' )
		
	set @constraint = ''
	select @constraint = name from sys.foreign_keys WHERE OBJECT_NAME(parent_object_id) = 'tblHDProjectModule' and OBJECT_NAME(referenced_object_id) = 'tblEntityContact'
	if(@constraint <> '')
		exec('ALTER TABLE tblHDProjectModule DROP CONSTRAINT [' + @constraint +']' )
	
	set @constraint = ''
	select @constraint = name from sys.foreign_keys WHERE  OBJECT_NAME(parent_object_id) = 'tblARCustomerToContact' and OBJECT_NAME(referenced_object_id) = 'tblARCustomer' 
	if(@constraint <> '')
		exec('ALTER TABLE tblARCustomerToContact DROP CONSTRAINT [' + @constraint +']' )
	
	set @constraint = ''
	select @constraint = name from sys.foreign_keys WHERE  OBJECT_NAME(parent_object_id) = 'tblAPVendorToContact' and OBJECT_NAME(referenced_object_id) = 'tblEntityContact' 
	if(@constraint <> '')
		exec('ALTER TABLE tblAPVendorToContact DROP CONSTRAINT [' + @constraint +']' )
	
	set @constraint = ''
	select @constraint = name from sys.foreign_keys WHERE  OBJECT_NAME(parent_object_id) = 'tblARCustomerToContact' and OBJECT_NAME(referenced_object_id) = 'tblEntityContact' 
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
		print('ALTER TABLE tblARCustomerProductVersion DROP CONSTRAINT [' + @constraint +']' )

	print 'Adding tblEntityContact columns to tblEntity'
	exec(N'	
	alter table tblEntity
	add [strContactNumber] [nvarchar](20) NOT NULL Default('''')

	alter table tblEntity
	add [strTitle] [nvarchar](35) NULL

	alter table tblEntity
	add [strDepartment] [nvarchar](30) NULL
		
	alter table tblEntity
	add [strMobile] [nvarchar](25) NULL

	alter table tblEntity
	add [strPhone] [nvarchar](25) NULL

	alter table tblEntity
	add [strPhone2] [nvarchar](25) NULL

	alter table tblEntity
	add [strEmail2] [nvarchar](75) NULL

	alter table tblEntity
	add [strFax] [nvarchar](25) NULL
		
	alter table tblEntity
	add [strNotes] [nvarchar](max) NULL
		
	alter table tblEntity
	add [strContactMethod] [nvarchar](20) NULL

	alter table tblEntity
	add [strTimezone] [nvarchar](100) NULL

	alter table tblEntity
	add [strEntityNo] [nvarchar](100) NULL
		
	alter table tblEntity
	add [ysnActive] [bit] NOT NULL DEFAULT ((1))


	alter table tblEntity
	add [intDefaultLocationId]       INT            NULL ')

	print 'Update tblEntity strEntityNo to get the Vendor strVendorId'
	IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblEntity' AND [COLUMN_NAME] = 'strEntityNo') 
	BEGIN
		exec(N' update a set a.strEntityNo = b.strVendorId
				from tblEntity a
					join tblAPVendor b
						on a.intEntityId =  b.intEntityId ')
	END

	print 'Update tblEntity strEntityNo to get the tblARCustomer strCustomerNumber'
	IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblEntity' AND [COLUMN_NAME] = 'strEntityNo') 
	BEGIN
		exec(N' update a set a.strEntityNo = b.strCustomerNumber
				from tblEntity a
					join tblARCustomer b
						on a.intEntityId =  b.intEntityId ')
	END


	print 'Moving Default Location'
	exec(N'				
			update a set a.intDefaultLocationId = b.intDefaultLocationId from tblEntity  a
				join tblAPVendor b
					on a.intEntityId = b.intEntityId				
					
			update a set a.intDefaultLocationId=b.intDefaultLocationId from tblEntity  a
				join tblARCustomer b
					on a.intEntityId = b.intEntityId
		')
	
	print 'check if the ysnActive is available in tblEntityContact'
	 IF NOT EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblEntityContact' AND [COLUMN_NAME] = 'ysnActive') 
	 BEGIN
	  exec(N'alter table tblEntityContact 
		add [ysnActive] [bit] NOT NULL DEFAULT ((1))')
	 END

	print 'Moving Entity Contact Data to Entity'
	exec(N'	
			update a set
					a.strContactNumber = b.strContactNumber,	
					a.strTitle = b.strTitle,
					a.strDepartment = b.strDepartment,
					a.strMobile = b.strMobile,
					a.strPhone = b.strPhone,
					a.strPhone2 = b.strPhone2,
					a.strEmail2 = b.strEmail2,
					a.strFax = b.strFax,
					a.strNotes = b.strNotes,
					a.strContactMethod = b.strContactMethod,
					a.strTimezone = b.strTimezone,
					a.ysnActive = b.ysnActive
							
				from tblEntity a
					join tblEntityContact b
						on a.intEntityId = b.intEntityId')


	print 'Moving linking to entity id instead of vendor id'
	IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblAPVendorToContact' AND [COLUMN_NAME] = 'intVendorId') 
	BEGIN
		exec(N'	
				update a set a.intVendorId = b.intEntityId
					from tblAPVendorToContact a
						join tblAPVendor b
							on a.intVendorId = b.intVendorId')
	END

	
	print 'Adding Default Contact to Vendor To Contact'
	exec(N'	ALTER TABLE tblAPVendorToContact
			add ysnDefaultContact bit')

	print 'Adding user type to Vendor To Contact'
	exec(N' ALTER TABLE tblAPVendorToContact
			add strUserType [nvarchar](20) NOT NULL Default('''')')
		
	print 'Update vendor to contact default contact column'
	IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblAPVendorToContact' AND [COLUMN_NAME] = 'ysnDefaultContact') 
	BEGIN
		exec(N' update b set b.ysnDefaultContact = 1 
					from tblAPVendor a
						join tblAPVendorToContact b
							on a.intDefaultContactId = b.intContactId ')
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
	exec(N'	
			ALTER TABLE tblARCustomerToContact
			add ysnDefaultContact bit')


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
			join tblEntityContact b 
				on a.intCustomerContactId = b.intContactId')
	END

	
	print 'Update Linking of tblHDProject intCustomerLeadershipSponsor from entity contact to entity id'
	IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblHDProject' AND [COLUMN_NAME] = 'intCustomerLeadershipSponsor') 
	BEGIN
		exec(N'		
				UPDATE a set a.intCustomerLeadershipSponsor = b.intEntityId
					from tblHDProject a 
						join tblEntityContact b 
							on a.intCustomerLeadershipSponsor = b.intContactId')
	END
	
					
	print 'Update Linking of tblHDProject intCustomerProjectManager from entity contact to entity id'
	IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblHDProject' AND [COLUMN_NAME] = 'intCustomerProjectManager') 
	BEGIN
		exec(N'	
				UPDATE a set a.intCustomerProjectManager = b.intEntityId
					from tblHDProject a 
						join tblEntityContact b 
							on a.intCustomerProjectManager = b.intContactId	')
	END		
							
	
	print 'Update Linking of tblHDProjectModule from entity contact to entity id'
	IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblHDProjectModule' AND [COLUMN_NAME] = 'intContactId') 
	BEGIN
		exec(N'
				UPDATE a set a.intContactId = b.intEntityId
					from tblHDProjectModule a 
						join tblEntityContact b 
							on a.intContactId = b.intContactId	')
	END
	
	print 'Update Linking of tblAPVendorToContact from entity contact to entity id'
	IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblAPVendorToContact' AND [COLUMN_NAME] = 'intContactId') 
	BEGIN
		exec(N'
				UPDATE a set a.intContactId = b.intEntityId
					from tblAPVendorToContact a 
						join tblEntityContact b 
							on a.intContactId = b.intContactId	')
	END

	print 'Update Linking of tblARCustomerToContact from entity contact to entity id'
	IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblARCustomerToContact' AND [COLUMN_NAME] = 'intContactId') 
	BEGIN
		exec(N'
				UPDATE a set a.intContactId = b.intEntityId
					from tblARCustomerToContact a 
						join tblEntityContact b 
							on a.intContactId = b.intContactId		')		
	END


	print 'Update Linking of tblAPVendor default contact from entity contact to entity id'
	IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblAPVendor' AND [COLUMN_NAME] = 'intDefaultContactId') 
	BEGIN
		exec(N'						
				UPDATE a set a.intDefaultContactId = b.intEntityId
					from tblAPVendor a 
						join tblEntityContact b 
							on a.intDefaultContactId = b.intContactId		')	
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

	print 'Update Linking of tblICInventoryReceipt intVendorId from intVendorId to entityid '
	 IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblICInventoryReceipt' AND [COLUMN_NAME] = 'intVendorId') 
	 BEGIN
		  exec(N' UPDATE a set a.intVendorId = b.intEntityId
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
	exec(N'		
			delete from tblEntityToContact	where intEntityId not in ( select intEntityId from tblEntity)
			
			delete from tblEntityToContact	where intContactId not in ( select intEntityId from tblEntityContact)

			')


	print 'add locationid to tblEntityToContact'
	exec(N'		
			alter table tblEntityToContact
			add [intEntityLocationId]        INT NULL ')
			
	print 'Add strUserType tblEnttiyToContact'
	exec(N'		
			alter table tblEntityToContact
			add [strUserType]              NVARCHAR (5) COLLATE Latin1_General_CI_AS NULL ')
	print 'Add ysnPortalAccess to EntityToContact'
	exec(N'		
			alter table tblEntityToContact
			add [ysnPortalAccess]          BIT          NULL ')
	print 'Add ysnDefaultContact to EntityToContact'
	exec(N'					
			alter table tblEntityToContact
			add [ysnDefaultContact] BIT NOT NULL DEFAULT ((0))')
	print 'move tblARCustomerToContact to tblEntityToContact'
	exec(N'		
			INSERT INTO tblEntityToContact 
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
	print 'move tblAPVendorToContact to tblEntityToContact'
	exec(N'		
			INSERT INTO tblEntityToContact 
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
		
	print 'Update entity type for customer '
	exec(N'		
			insert into tblEntityType(intEntityId,strType,intConcurrencyId)
			select b.intEntityId,''Customer'',0 from tblARCustomer a
				join tblEntity b
					on a.intEntityId = b.intEntityId
				where b.intEntityId not in (select intEntityId from tblEntityType)	')
	
	print 'Update entity type for Vendor'
	exec(N'		
			insert into tblEntityType(intEntityId,strType,intConcurrencyId)
			select b.intEntityId,''Vendor'',0 from tblAPVendor a
				join tblEntity b
					on a.intEntityId = b.intEntityId
				where b.intEntityId not in (select intEntityId from tblEntityType)	')

	print 'Update entity type for salesperson'
	exec(N'		
			insert into tblEntityType(intEntityId,strType,intConcurrencyId)
			select b.intEntityId,''Salesperson'',0 from tblARSalesperson a
				join tblEntity b
					on a.intEntityId = b.intEntityId
				where b.intEntityId not in (select intEntityId from tblEntityType)	')

	print 'Update entity type for User'
	exec(N'		
			insert into tblEntityType(intEntityId,strType,intConcurrencyId)		
			select b.intEntityId,''User'',0 from tblSMUserSecurity a
				join tblEntity b
					on a.intEntityId = b.intEntityId
				where b.intEntityId not in (select intEntityId from tblEntityType)	')

	print 'Update Linking of tblPOPurchase from vendor id to entity id'
	IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblPOPurchase' AND [COLUMN_NAME] = 'intVendorId') 
	BEGIN
		exec(N' update a set a.intVendorId = b.intEntityId
				from tblPOPurchase a
					join tblAPVendor b
						on a.intVendorId =  b.intVendorId ')
	END

	print 'Update Linking of tblICInventoryReceipt from vendor id to entity id'
	IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblICInventoryReceipt' AND [COLUMN_NAME] = 'intVendorId') 
	BEGIN
		exec(N' update a set a.intVendorId = b.intEntityId
				from tblICInventoryReceipt a
					join tblAPVendor b
						on a.intVendorId =  b.intVendorId ')
	END

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

END