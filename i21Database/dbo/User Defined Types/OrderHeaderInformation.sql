CREATE TYPE [dbo].[OrderHeaderInformation] AS TABLE (
	 [intId]							INT IDENTITY PRIMARY KEY CLUSTERED
	,[intOrderStatusId]					INT
	,[intOrderTypeId]					INT
	,[intOrderDirectionId]				INT
	,[strOrderNo]						NVARCHAR(50)
	,[strReferenceNo]					NVARCHAR(50)
	,[intStagingLocationId]				INT
	,[intWorkOrderId]					NVARCHAR(MAX)
	,[strComment]						INT NULL
	,[dtmOrderDate]						DateTime NULL
	,[strLastUpdateBy]					NVARCHAR(100)
	)