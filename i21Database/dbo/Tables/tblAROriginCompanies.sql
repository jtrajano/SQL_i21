
CREATE TABLE [dbo].[tblAROriginCompanies](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[strCustomer_lic_co] [varchar](50) COLLATE Latin1_General_CI_AS NOT NULL,
	[strCustomer_lic_name] [varchar](50) COLLATE Latin1_General_CI_AS NULL,
	[strCustomer_addr] [varchar](30) COLLATE Latin1_General_CI_AS NULL,
	[strCustomer_addr2] [varchar](30) COLLATE Latin1_General_CI_AS NULL,
	[strCustomer_city] [varchar](20) COLLATE Latin1_General_CI_AS NULL,
	[strCustomer_state] [char](2) COLLATE Latin1_General_CI_AS NULL,
	[strCustomer_zip] [varchar](10) COLLATE Latin1_General_CI_AS NULL,
	[strCustomer_ser_no] [varchar](50) COLLATE Latin1_General_CI_AS NULL,
	[dtCustomer_install_dt] [varchar](50) COLLATE Latin1_General_CI_AS NULL,
	[strCustomer_release_no] [varchar](50) COLLATE Latin1_General_CI_AS NULL,
	[strCompany_co] [char](2) COLLATE Latin1_General_CI_AS NOT NULL,
	[strCompany_name] [varchar](50) COLLATE Latin1_General_CI_AS NULL,
	[dtServpack_apply_dt] [date] NULL,
	[strServpack_build_no] [varchar](4) COLLATE Latin1_General_CI_AS NULL,
	[intServpack_build_rev] [int] NULL,
	[strServpack_build_filename] [varchar](15) COLLATE Latin1_General_CI_AS NULL,
	[strOperating_system] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[strACU_Version] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[strDB_Version] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[irDateTime] [datetime] NOT NULL CONSTRAINT [DF_tblHDCompanies1_irDateTime_1]  DEFAULT (getdate()),
	[irUser] [varchar](150) COLLATE Latin1_General_CI_AS NOT NULL CONSTRAINT [DF_tblHDCompanies1_irUser_1]  DEFAULT (suser_name()),
 CONSTRAINT [PK_tblHDCompanies] PRIMARY KEY CLUSTERED 
(
	[strCustomer_lic_co] ASC,
	[strCompany_co] ASC
)
) ON [PRIMARY]
