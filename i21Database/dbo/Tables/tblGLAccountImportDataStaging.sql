CREATE TABLE tblGLAccountImportDataStaging (  
 [strPrimarySegment] [nvarchar](40) COLLATE Latin1_General_CI_AS NOT NULL,  
 [strLocationSegment] [nvarchar](40) COLLATE Latin1_General_CI_AS NOT NULL,  
 [strLOBSegment] [nvarchar](40) COLLATE Latin1_General_CI_AS NULL,  
 [strDescription] [nvarchar](500) COLLATE Latin1_General_CI_AS NULL,  
 [strUOM] [nvarchar](20) COLLATE Latin1_General_CI_AS NULL ,
 [strGUID] nvarchar(40) COLLATE Latin1_General_CI_AS NULL ,
 [strRawString] nvarchar(MAX) COLLATE Latin1_General_CI_AS NULL
)  
   