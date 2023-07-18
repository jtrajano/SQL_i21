CREATE TABLE [dbo].[tblSMUpload] (
    [intUploadId]               INT              IDENTITY (1, 1) NOT NULL,
    [intAttachmentId]           INT              NULL,
    [strFileIdentifier]         UNIQUEIDENTIFIER NOT NULL,
    [blbFile]                   VARBINARY (MAX)  NULL,
    [ysnOptimized]              BIT              NULL,
    [intOptimizedSize]          INT              NULL,
    [dtmDateUploaded]           DATETIME         NOT NULL,
    [ysnIsUploadedToAzureBlob]  BIT              NOT NULL DEFAULT 0,
    [dtmDateUploadedToAzureBlob] DATETIME         NULL,
    [ysnSkipAzureUpload]        BIT             NOT NULL DEFAULT 0,
    [intConcurrencyId]          INT              NOT NULL,
    CONSTRAINT [PK_tblUpload] PRIMARY KEY CLUSTERED ([intUploadId] ASC),
    CONSTRAINT [FK_tblSMUpload_tblSMAttachment] FOREIGN KEY ([intAttachmentId]) REFERENCES [dbo].[tblSMAttachment] ([intAttachmentId]) ON DELETE CASCADE
);

GO

CREATE INDEX [IX_tblSMUpload_intAttachmentId] ON [dbo].[tblSMUpload] ([intAttachmentId]) INCLUDE([blbFile])

GO

CREATE TRIGGER trgInsteadOfInsertSMUpload
            ON [dbo].tblSMUpload
			INSTEAD OF INSERT
			AS
			BEGIN

			SET NOCOUNT ON;

            -- Get the storage limit
            DECLARE @storageLimit FLOAT;
            SELECT @storageLimit = CONVERT(FLOAT, intMaxAttachmentStorage)
            FROM tblSMLicense

            -- Calculate the current total storage used in GB
            DECLARE @currentStorageSize FLOAT;
            SELECT @currentStorageSize = CONVERT(FLOAT, SUM(reserved_page_count * 8.0 /1024 / 1024)) 
            FROM sys.dm_db_partition_stats 
            WHERE object_id = OBJECT_ID('tblSMUpload')
            
            -- Calculate the size of the new file(s) being inserted
            DECLARE @fileSize FLOAT;
            SELECT @fileSize = CONVERT(FLOAT, SUM(DATALENGTH(blbFile)))
            FROM inserted;
            IF (@currentStorageSize + (@fileSize / (1024 * 1024 * 1024))) > @StorageLimit
            BEGIN
                DECLARE @currentStorageSizeString VARCHAR(10)
                SELECT @currentStorageSizeString = CAST(@currentStorageSize AS VARCHAR)

                RAISERROR(
				N'Storage limit exceeded with the limit of %s GB. Insertion cancelled.'
				, 16
				, 1
				, @currentStorageSizeString);

                RETURN;
            END;

            -- Proceed with the insertion
            INSERT INTO tblSMUpload (
                  intAttachmentId         
                , strFileIdentifier      
                , blbFile               
                , ysnOptimized           
                , intOptimizedSize        
                , dtmDateUploaded          
                , ysnIsUploadedToAzureBlob
                , dtmDateUploadedToAzureBlob
                , ysnSkipAzureUpload    
                , intConcurrencyId
            )
			SELECT 
                  intAttachmentId        
                , strFileIdentifier       
                , blbFile              
                , ysnOptimized       
                , intOptimizedSize        
                , dtmDateUploaded       
                , ysnIsUploadedToAzureBlob
                , dtmDateUploadedToAzureBlob
                , ysnSkipAzureUpload      
                , intConcurrencyId
			FROM inserted

            -- https://github.com/dotnet/efcore/issues/12064
            -- https://stackoverflow.com/a/26897952/13726696
            SELECT intUploadId FROM tblSMUpload WHERE @@ROWCOUNT > 0 AND intUploadId = SCOPE_IDENTITY()
END