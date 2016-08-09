CREATE TYPE [dbo].[OrderHeaderInformation] AS TABLE (
	 [intId]							INT IDENTITY PRIMARY KEY CLUSTERED
	,[intOrderStatusId]					INT
	,[intOrderTypeId]					INT
	,[intOrderDirectionId]				INT
	,[strOrderNo]						INT
	,[strReferenceNo]					INT
	,[intStagingLocationId]				INT
	,[intWorkOrderId]					NVARCHAR(MAX)
	,[strComment]						INT NULL
	,[dtmOrderDate]						INT NULL
	,[strLastUpdateBy]					NVARCHAR(100)
	)