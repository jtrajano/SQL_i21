namespace iRely.Inventory.WebApi.Reports
{
    partial class PhysicalInventoryCount
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary> 
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            this.components = new System.ComponentModel.Container();
            DevExpress.XtraPrinting.BarCode.Code128Generator code128Generator1 = new DevExpress.XtraPrinting.BarCode.Code128Generator();
            DevExpress.DataAccess.ConnectionParameters.MsSqlConnectionParameters msSqlConnectionParameters1 = new DevExpress.DataAccess.ConnectionParameters.MsSqlConnectionParameters();
            DevExpress.DataAccess.Sql.StoredProcQuery storedProcQuery1 = new DevExpress.DataAccess.Sql.StoredProcQuery();
            DevExpress.DataAccess.Sql.QueryParameter queryParameter1 = new DevExpress.DataAccess.Sql.QueryParameter();
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(PhysicalInventoryCount));
            this.Detail = new DevExpress.XtraReports.UI.DetailBand();
            this.xrTable3 = new DevExpress.XtraReports.UI.XRTable();
            this.xrTableRow3 = new DevExpress.XtraReports.UI.XRTableRow();
            this.valueCountLineNo = new DevExpress.XtraReports.UI.XRTableCell();
            this.valueItemNo = new DevExpress.XtraReports.UI.XRTableCell();
            this.valueDesc = new DevExpress.XtraReports.UI.XRTableCell();
            this.valueStorageLocation = new DevExpress.XtraReports.UI.XRTableCell();
            this.valueLotID = new DevExpress.XtraReports.UI.XRTableCell();
            this.valueUnitOfMeasure = new DevExpress.XtraReports.UI.XRTableCell();
            this.valueNoOfPallets = new DevExpress.XtraReports.UI.XRTableCell();
            this.valueQtyPerPallet = new DevExpress.XtraReports.UI.XRTableCell();
            this.valuePhysicalCount = new DevExpress.XtraReports.UI.XRTableCell();
            this.TopMargin = new DevExpress.XtraReports.UI.TopMarginBand();
            this.BottomMargin = new DevExpress.XtraReports.UI.BottomMarginBand();
            this.PageHeader = new DevExpress.XtraReports.UI.PageHeaderBand();
            this.lblCountID2 = new DevExpress.XtraReports.UI.XRLabel();
            this.valueCountNo2 = new DevExpress.XtraReports.UI.XRLabel();
            this.xrTable1 = new DevExpress.XtraReports.UI.XRTable();
            this.xrTableRow1 = new DevExpress.XtraReports.UI.XRTableRow();
            this.lblCountLineNo = new DevExpress.XtraReports.UI.XRTableCell();
            this.lblItemNo = new DevExpress.XtraReports.UI.XRTableCell();
            this.lblDesc = new DevExpress.XtraReports.UI.XRTableCell();
            this.lblStorageLocation = new DevExpress.XtraReports.UI.XRTableCell();
            this.lblLotID = new DevExpress.XtraReports.UI.XRTableCell();
            this.lblUnitOfMeasure = new DevExpress.XtraReports.UI.XRTableCell();
            this.lblNoOfPallets = new DevExpress.XtraReports.UI.XRTableCell();
            this.lblQtyPerPallet = new DevExpress.XtraReports.UI.XRTableCell();
            this.lblPhysicalCount = new DevExpress.XtraReports.UI.XRTableCell();
            this.valScannedCountEntry = new DevExpress.XtraReports.UI.XRLabel();
            this.valCountByPallets = new DevExpress.XtraReports.UI.XRLabel();
            this.valCountByLots = new DevExpress.XtraReports.UI.XRLabel();
            this.valueCountNo = new DevExpress.XtraReports.UI.XRLabel();
            this.valueCountDesc = new DevExpress.XtraReports.UI.XRLabel();
            this.valueCountDate = new DevExpress.XtraReports.UI.XRLabel();
            this.lblCountID = new DevExpress.XtraReports.UI.XRLabel();
            this.lblCountDesc = new DevExpress.XtraReports.UI.XRLabel();
            this.barCodeCountNo = new DevExpress.XtraReports.UI.XRBarCode();
            this.lblDate = new DevExpress.XtraReports.UI.XRLabel();
            this.xrLabel17 = new DevExpress.XtraReports.UI.XRLabel();
            this.PageFooter = new DevExpress.XtraReports.UI.PageFooterBand();
            this.xrPageInfo2 = new DevExpress.XtraReports.UI.XRPageInfo();
            this.sqlDataSource1 = new DevExpress.DataAccess.Sql.SqlDataSource();
            this.xpDataView1 = new DevExpress.Xpo.XPDataView(this.components);
            this.xpDataView2 = new DevExpress.Xpo.XPDataView(this.components);
            this.xpDataView3 = new DevExpress.Xpo.XPDataView(this.components);
            this.GroupHeader1 = new DevExpress.XtraReports.UI.GroupHeaderBand();
            this.xrLabel1 = new DevExpress.XtraReports.UI.XRLabel();
            this.GroupHeader2 = new DevExpress.XtraReports.UI.GroupHeaderBand();
            this.xrLabel2 = new DevExpress.XtraReports.UI.XRLabel();
            this.xrLabel3 = new DevExpress.XtraReports.UI.XRLabel();
            this.xrLabel4 = new DevExpress.XtraReports.UI.XRLabel();
            this.xrLabel5 = new DevExpress.XtraReports.UI.XRLabel();
            this.xrLabel6 = new DevExpress.XtraReports.UI.XRLabel();
            ((System.ComponentModel.ISupportInitialize)(this.xrTable3)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.xrTable1)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.xpDataView1)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.xpDataView2)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.xpDataView3)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this)).BeginInit();
            // 
            // Detail
            // 
            this.Detail.Controls.AddRange(new DevExpress.XtraReports.UI.XRControl[] {
            this.xrTable3});
            this.Detail.Dpi = 254F;
            this.Detail.HeightF = 150.8125F;
            this.Detail.KeepTogetherWithDetailReports = true;
            this.Detail.Name = "Detail";
            this.Detail.Padding = new DevExpress.XtraPrinting.PaddingInfo(0, 0, 0, 0, 254F);
            this.Detail.StylePriority.UseTextAlignment = false;
            this.Detail.TextAlignment = DevExpress.XtraPrinting.TextAlignment.MiddleLeft;
            // 
            // xrTable3
            // 
            this.xrTable3.BorderColor = System.Drawing.Color.DimGray;
            this.xrTable3.Borders = ((DevExpress.XtraPrinting.BorderSide)(((DevExpress.XtraPrinting.BorderSide.Left | DevExpress.XtraPrinting.BorderSide.Right) 
            | DevExpress.XtraPrinting.BorderSide.Bottom)));
            this.xrTable3.BorderWidth = 2F;
            this.xrTable3.Dpi = 254F;
            this.xrTable3.Font = new System.Drawing.Font("Arial", 9F);
            this.xrTable3.LocationFloat = new DevExpress.Utils.PointFloat(0F, 0F);
            this.xrTable3.Name = "xrTable3";
            this.xrTable3.Padding = new DevExpress.XtraPrinting.PaddingInfo(8, 5, 11, 5, 254F);
            this.xrTable3.Rows.AddRange(new DevExpress.XtraReports.UI.XRTableRow[] {
            this.xrTableRow3});
            this.xrTable3.SizeF = new System.Drawing.SizeF(1950.001F, 150.8125F);
            this.xrTable3.StylePriority.UseBorderColor = false;
            this.xrTable3.StylePriority.UseBorders = false;
            this.xrTable3.StylePriority.UseBorderWidth = false;
            this.xrTable3.StylePriority.UseFont = false;
            this.xrTable3.StylePriority.UsePadding = false;
            this.xrTable3.StylePriority.UseTextAlignment = false;
            this.xrTable3.TextAlignment = DevExpress.XtraPrinting.TextAlignment.TopLeft;
            // 
            // xrTableRow3
            // 
            this.xrTableRow3.Cells.AddRange(new DevExpress.XtraReports.UI.XRTableCell[] {
            this.valueCountLineNo,
            this.valueItemNo,
            this.valueDesc,
            this.valueStorageLocation,
            this.valueLotID,
            this.valueUnitOfMeasure,
            this.valueNoOfPallets,
            this.valueQtyPerPallet,
            this.valuePhysicalCount});
            this.xrTableRow3.Dpi = 254F;
            this.xrTableRow3.Name = "xrTableRow3";
            this.xrTableRow3.Weight = 0.5679012345679012D;
            // 
            // valueCountLineNo
            // 
            this.valueCountLineNo.DataBindings.AddRange(new DevExpress.XtraReports.UI.XRBinding[] {
            new DevExpress.XtraReports.UI.XRBinding("Text", null, "uspICReportPhysicalInventoryCount.strCountLine")});
            this.valueCountLineNo.Dpi = 254F;
            this.valueCountLineNo.Name = "valueCountLineNo";
            this.valueCountLineNo.Weight = 0.10714862545537884D;
            // 
            // valueItemNo
            // 
            this.valueItemNo.DataBindings.AddRange(new DevExpress.XtraReports.UI.XRBinding[] {
            new DevExpress.XtraReports.UI.XRBinding("Text", null, "uspICReportPhysicalInventoryCount.strItemNo")});
            this.valueItemNo.Dpi = 254F;
            this.valueItemNo.Name = "valueItemNo";
            this.valueItemNo.Weight = 0.13088116488487883D;
            // 
            // valueDesc
            // 
            this.valueDesc.DataBindings.AddRange(new DevExpress.XtraReports.UI.XRBinding[] {
            new DevExpress.XtraReports.UI.XRBinding("Text", null, "uspICReportPhysicalInventoryCount.strItemDesc")});
            this.valueDesc.Dpi = 254F;
            this.valueDesc.Name = "valueDesc";
            this.valueDesc.Weight = 0.17069881595064107D;
            // 
            // valueStorageLocation
            // 
            this.valueStorageLocation.DataBindings.AddRange(new DevExpress.XtraReports.UI.XRBinding[] {
            new DevExpress.XtraReports.UI.XRBinding("Text", null, "uspICReportPhysicalInventoryCount.strStorageLocationName")});
            this.valueStorageLocation.Dpi = 254F;
            this.valueStorageLocation.Name = "valueStorageLocation";
            this.valueStorageLocation.Weight = 0.15187376370301453D;
            // 
            // valueLotID
            // 
            this.valueLotID.CanShrink = true;
            this.valueLotID.DataBindings.AddRange(new DevExpress.XtraReports.UI.XRBinding[] {
            new DevExpress.XtraReports.UI.XRBinding("Text", null, "uspICReportPhysicalInventoryCount.strLotName")});
            this.valueLotID.Dpi = 254F;
            this.valueLotID.Name = "valueLotID";
            this.valueLotID.Weight = 0.13870491151169459D;
            // 
            // valueUnitOfMeasure
            // 
            this.valueUnitOfMeasure.DataBindings.AddRange(new DevExpress.XtraReports.UI.XRBinding[] {
            new DevExpress.XtraReports.UI.XRBinding("Text", null, "uspICReportPhysicalInventoryCount.strUnitMeasure")});
            this.valueUnitOfMeasure.Dpi = 254F;
            this.valueUnitOfMeasure.Name = "valueUnitOfMeasure";
            this.valueUnitOfMeasure.Weight = 0.091165812977616487D;
            // 
            // valueNoOfPallets
            // 
            this.valueNoOfPallets.CanShrink = true;
            this.valueNoOfPallets.Dpi = 254F;
            this.valueNoOfPallets.Name = "valueNoOfPallets";
            this.valueNoOfPallets.TextAlignment = DevExpress.XtraPrinting.TextAlignment.TopRight;
            this.valueNoOfPallets.Weight = 0.11470179815790066D;
            // 
            // valueQtyPerPallet
            // 
            this.valueQtyPerPallet.CanShrink = true;
            this.valueQtyPerPallet.Dpi = 254F;
            this.valueQtyPerPallet.Name = "valueQtyPerPallet";
            this.valueQtyPerPallet.TextAlignment = DevExpress.XtraPrinting.TextAlignment.TopRight;
            this.valueQtyPerPallet.Weight = 0.11470207077457759D;
            // 
            // valuePhysicalCount
            // 
            this.valuePhysicalCount.Dpi = 254F;
            this.valuePhysicalCount.Name = "valuePhysicalCount";
            this.valuePhysicalCount.TextAlignment = DevExpress.XtraPrinting.TextAlignment.TopRight;
            this.valuePhysicalCount.Weight = 0.12714480232294065D;
            // 
            // TopMargin
            // 
            this.TopMargin.Dpi = 254F;
            this.TopMargin.HeightF = 93F;
            this.TopMargin.Name = "TopMargin";
            this.TopMargin.Padding = new DevExpress.XtraPrinting.PaddingInfo(0, 0, 0, 0, 254F);
            this.TopMargin.TextAlignment = DevExpress.XtraPrinting.TextAlignment.TopLeft;
            // 
            // BottomMargin
            // 
            this.BottomMargin.Dpi = 254F;
            this.BottomMargin.HeightF = 92F;
            this.BottomMargin.Name = "BottomMargin";
            this.BottomMargin.Padding = new DevExpress.XtraPrinting.PaddingInfo(0, 0, 0, 0, 254F);
            this.BottomMargin.TextAlignment = DevExpress.XtraPrinting.TextAlignment.TopLeft;
            // 
            // PageHeader
            // 
            this.PageHeader.Controls.AddRange(new DevExpress.XtraReports.UI.XRControl[] {
            this.xrLabel6,
            this.xrLabel5,
            this.xrLabel4,
            this.xrLabel3,
            this.lblCountID2,
            this.valueCountNo2,
            this.xrTable1,
            this.valScannedCountEntry,
            this.valCountByPallets,
            this.valCountByLots,
            this.valueCountNo,
            this.valueCountDesc,
            this.valueCountDate,
            this.lblCountID,
            this.lblCountDesc,
            this.barCodeCountNo,
            this.lblDate,
            this.xrLabel17});
            this.PageHeader.Dpi = 254F;
            this.PageHeader.HeightF = 664.1042F;
            this.PageHeader.Name = "PageHeader";
            // 
            // lblCountID2
            // 
            this.lblCountID2.BackColor = System.Drawing.Color.Gainsboro;
            this.lblCountID2.BorderColor = System.Drawing.Color.DimGray;
            this.lblCountID2.Borders = ((DevExpress.XtraPrinting.BorderSide)((((DevExpress.XtraPrinting.BorderSide.Left | DevExpress.XtraPrinting.BorderSide.Top) 
            | DevExpress.XtraPrinting.BorderSide.Right) 
            | DevExpress.XtraPrinting.BorderSide.Bottom)));
            this.lblCountID2.BorderWidth = 2F;
            this.lblCountID2.Dpi = 254F;
            this.lblCountID2.Font = new System.Drawing.Font("Arial", 9F, System.Drawing.FontStyle.Bold);
            this.lblCountID2.LocationFloat = new DevExpress.Utils.PointFloat(1478.724F, 347.685F);
            this.lblCountID2.Name = "lblCountID2";
            this.lblCountID2.Padding = new DevExpress.XtraPrinting.PaddingInfo(13, 13, 13, 0, 254F);
            this.lblCountID2.SizeF = new System.Drawing.SizeF(193.4633F, 77.68176F);
            this.lblCountID2.StylePriority.UseBackColor = false;
            this.lblCountID2.StylePriority.UseBorderColor = false;
            this.lblCountID2.StylePriority.UseBorders = false;
            this.lblCountID2.StylePriority.UseBorderWidth = false;
            this.lblCountID2.StylePriority.UseFont = false;
            this.lblCountID2.StylePriority.UsePadding = false;
            this.lblCountID2.StylePriority.UseTextAlignment = false;
            this.lblCountID2.Text = "Count ID:";
            this.lblCountID2.TextAlignment = DevExpress.XtraPrinting.TextAlignment.TopLeft;
            this.lblCountID2.Visible = false;
            // 
            // valueCountNo2
            // 
            this.valueCountNo2.BorderColor = System.Drawing.Color.DimGray;
            this.valueCountNo2.BorderDashStyle = DevExpress.XtraPrinting.BorderDashStyle.Solid;
            this.valueCountNo2.Borders = ((DevExpress.XtraPrinting.BorderSide)(((DevExpress.XtraPrinting.BorderSide.Top | DevExpress.XtraPrinting.BorderSide.Right) 
            | DevExpress.XtraPrinting.BorderSide.Bottom)));
            this.valueCountNo2.BorderWidth = 2F;
            this.valueCountNo2.DataBindings.AddRange(new DevExpress.XtraReports.UI.XRBinding[] {
            new DevExpress.XtraReports.UI.XRBinding("Text", null, "uspICReportPhysicalInventoryCount.strCountNo")});
            this.valueCountNo2.Dpi = 254F;
            this.valueCountNo2.Font = new System.Drawing.Font("Arial", 9F);
            this.valueCountNo2.LocationFloat = new DevExpress.Utils.PointFloat(1672.188F, 347.685F);
            this.valueCountNo2.Name = "valueCountNo2";
            this.valueCountNo2.Padding = new DevExpress.XtraPrinting.PaddingInfo(11, 11, 11, 0, 254F);
            this.valueCountNo2.SizeF = new System.Drawing.SizeF(277.8125F, 77.68173F);
            this.valueCountNo2.StylePriority.UseBorderColor = false;
            this.valueCountNo2.StylePriority.UseBorderDashStyle = false;
            this.valueCountNo2.StylePriority.UseBorders = false;
            this.valueCountNo2.StylePriority.UseBorderWidth = false;
            this.valueCountNo2.StylePriority.UseFont = false;
            this.valueCountNo2.StylePriority.UsePadding = false;
            this.valueCountNo2.Text = "valueCountNo2";
            this.valueCountNo2.Visible = false;
            // 
            // xrTable1
            // 
            this.xrTable1.BackColor = System.Drawing.Color.Gainsboro;
            this.xrTable1.BorderColor = System.Drawing.Color.DimGray;
            this.xrTable1.Borders = ((DevExpress.XtraPrinting.BorderSide)((((DevExpress.XtraPrinting.BorderSide.Left | DevExpress.XtraPrinting.BorderSide.Top) 
            | DevExpress.XtraPrinting.BorderSide.Right) 
            | DevExpress.XtraPrinting.BorderSide.Bottom)));
            this.xrTable1.BorderWidth = 2F;
            this.xrTable1.Dpi = 254F;
            this.xrTable1.Font = new System.Drawing.Font("Arial", 9F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.xrTable1.LocationFloat = new DevExpress.Utils.PointFloat(0F, 551.5208F);
            this.xrTable1.Name = "xrTable1";
            this.xrTable1.Padding = new DevExpress.XtraPrinting.PaddingInfo(8, 5, 11, 5, 254F);
            this.xrTable1.Rows.AddRange(new DevExpress.XtraReports.UI.XRTableRow[] {
            this.xrTableRow1});
            this.xrTable1.SizeF = new System.Drawing.SizeF(1949.999F, 112.5833F);
            this.xrTable1.StylePriority.UseBackColor = false;
            this.xrTable1.StylePriority.UseBorderColor = false;
            this.xrTable1.StylePriority.UseBorders = false;
            this.xrTable1.StylePriority.UseBorderWidth = false;
            this.xrTable1.StylePriority.UseFont = false;
            this.xrTable1.StylePriority.UsePadding = false;
            // 
            // xrTableRow1
            // 
            this.xrTableRow1.Cells.AddRange(new DevExpress.XtraReports.UI.XRTableCell[] {
            this.lblCountLineNo,
            this.lblItemNo,
            this.lblDesc,
            this.lblStorageLocation,
            this.lblLotID,
            this.lblUnitOfMeasure,
            this.lblNoOfPallets,
            this.lblQtyPerPallet,
            this.lblPhysicalCount});
            this.xrTableRow1.Dpi = 254F;
            this.xrTableRow1.Name = "xrTableRow1";
            this.xrTableRow1.Weight = 0.5679012345679012D;
            // 
            // lblCountLineNo
            // 
            this.lblCountLineNo.Dpi = 254F;
            this.lblCountLineNo.Name = "lblCountLineNo";
            this.lblCountLineNo.Text = "Count Line No.";
            this.lblCountLineNo.Weight = 0.10714868751650225D;
            // 
            // lblItemNo
            // 
            this.lblItemNo.Dpi = 254F;
            this.lblItemNo.Name = "lblItemNo";
            this.lblItemNo.Text = "Item No.";
            this.lblItemNo.Weight = 0.13088124505840923D;
            // 
            // lblDesc
            // 
            this.lblDesc.Dpi = 254F;
            this.lblDesc.Name = "lblDesc";
            this.lblDesc.Text = "Description";
            this.lblDesc.Weight = 0.17069869613968569D;
            // 
            // lblStorageLocation
            // 
            this.lblStorageLocation.Dpi = 254F;
            this.lblStorageLocation.Name = "lblStorageLocation";
            this.lblStorageLocation.Text = "Storage Unit";
            this.lblStorageLocation.Weight = 0.15187369082599467D;
            // 
            // lblLotID
            // 
            this.lblLotID.CanShrink = true;
            this.lblLotID.Dpi = 254F;
            this.lblLotID.Name = "lblLotID";
            this.lblLotID.Text = "Lot ID";
            this.lblLotID.Weight = 0.13870535134207296D;
            // 
            // lblUnitOfMeasure
            // 
            this.lblUnitOfMeasure.Dpi = 254F;
            this.lblUnitOfMeasure.Name = "lblUnitOfMeasure";
            this.lblUnitOfMeasure.Text = "Unit of Measure";
            this.lblUnitOfMeasure.Weight = 0.091165513295353315D;
            // 
            // lblNoOfPallets
            // 
            this.lblNoOfPallets.CanShrink = true;
            this.lblNoOfPallets.Dpi = 254F;
            this.lblNoOfPallets.Name = "lblNoOfPallets";
            this.lblNoOfPallets.Padding = new DevExpress.XtraPrinting.PaddingInfo(8, 8, 11, 5, 254F);
            this.lblNoOfPallets.StylePriority.UseBorders = false;
            this.lblNoOfPallets.StylePriority.UseBorderWidth = false;
            this.lblNoOfPallets.StylePriority.UsePadding = false;
            this.lblNoOfPallets.Text = "No. of Pallets";
            this.lblNoOfPallets.TextAlignment = DevExpress.XtraPrinting.TextAlignment.TopRight;
            this.lblNoOfPallets.Weight = 0.11470221358256573D;
            // 
            // lblQtyPerPallet
            // 
            this.lblQtyPerPallet.CanShrink = true;
            this.lblQtyPerPallet.Dpi = 254F;
            this.lblQtyPerPallet.Name = "lblQtyPerPallet";
            this.lblQtyPerPallet.Padding = new DevExpress.XtraPrinting.PaddingInfo(8, 8, 11, 5, 254F);
            this.lblQtyPerPallet.StylePriority.UsePadding = false;
            this.lblQtyPerPallet.Text = "Qty Per Pallet";
            this.lblQtyPerPallet.TextAlignment = DevExpress.XtraPrinting.TextAlignment.TopRight;
            this.lblQtyPerPallet.Weight = 0.11470220844277847D;
            // 
            // lblPhysicalCount
            // 
            this.lblPhysicalCount.Dpi = 254F;
            this.lblPhysicalCount.Name = "lblPhysicalCount";
            this.lblPhysicalCount.Padding = new DevExpress.XtraPrinting.PaddingInfo(8, 8, 11, 5, 254F);
            this.lblPhysicalCount.StylePriority.UsePadding = false;
            this.lblPhysicalCount.Text = "Physical Count";
            this.lblPhysicalCount.TextAlignment = DevExpress.XtraPrinting.TextAlignment.TopRight;
            this.lblPhysicalCount.Weight = 0.127144159535281D;
            // 
            // valScannedCountEntry
            // 
            this.valScannedCountEntry.DataBindings.AddRange(new DevExpress.XtraReports.UI.XRBinding[] {
            new DevExpress.XtraReports.UI.XRBinding("Text", null, "uspICReportPhysicalInventoryCount.ysnScannedCountEntry")});
            this.valScannedCountEntry.Dpi = 254F;
            this.valScannedCountEntry.LocationFloat = new DevExpress.Utils.PointFloat(1813.286F, 83.81998F);
            this.valScannedCountEntry.Name = "valScannedCountEntry";
            this.valScannedCountEntry.Padding = new DevExpress.XtraPrinting.PaddingInfo(5, 5, 0, 0, 254F);
            this.valScannedCountEntry.SizeF = new System.Drawing.SizeF(136.7139F, 58.41999F);
            this.valScannedCountEntry.Text = "valScannedCountEntry";
            this.valScannedCountEntry.BeforePrint += new System.Drawing.Printing.PrintEventHandler(this.valScannedCountEntry_BeforePrint);
            // 
            // valCountByPallets
            // 
            this.valCountByPallets.DataBindings.AddRange(new DevExpress.XtraReports.UI.XRBinding[] {
            new DevExpress.XtraReports.UI.XRBinding("Text", null, "uspICReportPhysicalInventoryCount.ysnCountByPallets")});
            this.valCountByPallets.Dpi = 254F;
            this.valCountByPallets.LocationFloat = new DevExpress.Utils.PointFloat(1643.953F, 83.81998F);
            this.valCountByPallets.Name = "valCountByPallets";
            this.valCountByPallets.Padding = new DevExpress.XtraPrinting.PaddingInfo(5, 5, 0, 0, 254F);
            this.valCountByPallets.SizeF = new System.Drawing.SizeF(169.3334F, 58.41999F);
            this.valCountByPallets.Text = "valCountByPallets";
            this.valCountByPallets.BeforePrint += new System.Drawing.Printing.PrintEventHandler(this.valCountByPallets_BeforePrint);
            // 
            // valCountByLots
            // 
            this.valCountByLots.DataBindings.AddRange(new DevExpress.XtraReports.UI.XRBinding[] {
            new DevExpress.XtraReports.UI.XRBinding("Text", null, "uspICReportPhysicalInventoryCount.ysnCountByLots")});
            this.valCountByLots.Dpi = 254F;
            this.valCountByLots.LocationFloat = new DevExpress.Utils.PointFloat(1445.515F, 83.81994F);
            this.valCountByLots.Name = "valCountByLots";
            this.valCountByLots.Padding = new DevExpress.XtraPrinting.PaddingInfo(5, 5, 0, 0, 254F);
            this.valCountByLots.SizeF = new System.Drawing.SizeF(198.4375F, 58.41999F);
            this.valCountByLots.Text = "valCountByLots";
            this.valCountByLots.BeforePrint += new System.Drawing.Printing.PrintEventHandler(this.valCountByLots_BeforePrint);
            // 
            // valueCountNo
            // 
            this.valueCountNo.DataBindings.AddRange(new DevExpress.XtraReports.UI.XRBinding[] {
            new DevExpress.XtraReports.UI.XRBinding("Text", null, "uspICReportPhysicalInventoryCount.strCountNo")});
            this.valueCountNo.Dpi = 254F;
            this.valueCountNo.Font = new System.Drawing.Font("Arial", 9F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.valueCountNo.LocationFloat = new DevExpress.Utils.PointFloat(1254.145F, 289.265F);
            this.valueCountNo.Name = "valueCountNo";
            this.valueCountNo.Padding = new DevExpress.XtraPrinting.PaddingInfo(11, 11, 11, 0, 254F);
            this.valueCountNo.SizeF = new System.Drawing.SizeF(695.8542F, 58.42001F);
            this.valueCountNo.StylePriority.UseFont = false;
            this.valueCountNo.StylePriority.UsePadding = false;
            this.valueCountNo.StylePriority.UseTextAlignment = false;
            this.valueCountNo.Text = "valueCountNo";
            this.valueCountNo.TextAlignment = DevExpress.XtraPrinting.TextAlignment.TopCenter;
            // 
            // valueCountDesc
            // 
            this.valueCountDesc.BorderColor = System.Drawing.Color.DimGray;
            this.valueCountDesc.BorderDashStyle = DevExpress.XtraPrinting.BorderDashStyle.Solid;
            this.valueCountDesc.Borders = ((DevExpress.XtraPrinting.BorderSide)((DevExpress.XtraPrinting.BorderSide.Right | DevExpress.XtraPrinting.BorderSide.Bottom)));
            this.valueCountDesc.BorderWidth = 2F;
            this.valueCountDesc.DataBindings.AddRange(new DevExpress.XtraReports.UI.XRBinding[] {
            new DevExpress.XtraReports.UI.XRBinding("Text", null, "uspICReportPhysicalInventoryCount.strInvCountDesc")});
            this.valueCountDesc.Dpi = 254F;
            this.valueCountDesc.Font = new System.Drawing.Font("Arial", 9F);
            this.valueCountDesc.LocationFloat = new DevExpress.Utils.PointFloat(246.38F, 228.4109F);
            this.valueCountDesc.Name = "valueCountDesc";
            this.valueCountDesc.Padding = new DevExpress.XtraPrinting.PaddingInfo(11, 11, 11, 0, 254F);
            this.valueCountDesc.SizeF = new System.Drawing.SizeF(701.1456F, 98.11006F);
            this.valueCountDesc.StylePriority.UseBorderColor = false;
            this.valueCountDesc.StylePriority.UseBorderDashStyle = false;
            this.valueCountDesc.StylePriority.UseBorders = false;
            this.valueCountDesc.StylePriority.UseBorderWidth = false;
            this.valueCountDesc.StylePriority.UseFont = false;
            this.valueCountDesc.StylePriority.UsePadding = false;
            this.valueCountDesc.Text = "valueCountDesc";
            // 
            // valueCountDate
            // 
            this.valueCountDate.BorderColor = System.Drawing.Color.DimGray;
            this.valueCountDate.BorderDashStyle = DevExpress.XtraPrinting.BorderDashStyle.Solid;
            this.valueCountDate.Borders = ((DevExpress.XtraPrinting.BorderSide)(((DevExpress.XtraPrinting.BorderSide.Top | DevExpress.XtraPrinting.BorderSide.Right) 
            | DevExpress.XtraPrinting.BorderSide.Bottom)));
            this.valueCountDate.BorderWidth = 2F;
            this.valueCountDate.DataBindings.AddRange(new DevExpress.XtraReports.UI.XRBinding[] {
            new DevExpress.XtraReports.UI.XRBinding("Text", null, "uspICReportPhysicalInventoryCount.dtmCountDate")});
            this.valueCountDate.Dpi = 254F;
            this.valueCountDate.Font = new System.Drawing.Font("Arial", 9F);
            this.valueCountDate.LocationFloat = new DevExpress.Utils.PointFloat(246.3799F, 150.7292F);
            this.valueCountDate.Name = "valueCountDate";
            this.valueCountDate.Padding = new DevExpress.XtraPrinting.PaddingInfo(11, 11, 11, 0, 254F);
            this.valueCountDate.SizeF = new System.Drawing.SizeF(701.1458F, 77.68175F);
            this.valueCountDate.StylePriority.UseBorderColor = false;
            this.valueCountDate.StylePriority.UseBorderDashStyle = false;
            this.valueCountDate.StylePriority.UseBorders = false;
            this.valueCountDate.StylePriority.UseBorderWidth = false;
            this.valueCountDate.StylePriority.UseFont = false;
            this.valueCountDate.StylePriority.UsePadding = false;
            this.valueCountDate.StylePriority.UseTextAlignment = false;
            this.valueCountDate.Text = "valueCountDate";
            this.valueCountDate.TextAlignment = DevExpress.XtraPrinting.TextAlignment.TopLeft;
            // 
            // lblCountID
            // 
            this.lblCountID.BackColor = System.Drawing.Color.Gainsboro;
            this.lblCountID.BorderColor = System.Drawing.Color.DimGray;
            this.lblCountID.Borders = ((DevExpress.XtraPrinting.BorderSide)((((DevExpress.XtraPrinting.BorderSide.Left | DevExpress.XtraPrinting.BorderSide.Top) 
            | DevExpress.XtraPrinting.BorderSide.Right) 
            | DevExpress.XtraPrinting.BorderSide.Bottom)));
            this.lblCountID.BorderWidth = 2F;
            this.lblCountID.Dpi = 254F;
            this.lblCountID.Font = new System.Drawing.Font("Arial", 9F, System.Drawing.FontStyle.Bold);
            this.lblCountID.LocationFloat = new DevExpress.Utils.PointFloat(1060.682F, 150.7292F);
            this.lblCountID.Name = "lblCountID";
            this.lblCountID.Padding = new DevExpress.XtraPrinting.PaddingInfo(13, 13, 13, 0, 254F);
            this.lblCountID.SizeF = new System.Drawing.SizeF(193.4633F, 77.68176F);
            this.lblCountID.StylePriority.UseBackColor = false;
            this.lblCountID.StylePriority.UseBorderColor = false;
            this.lblCountID.StylePriority.UseBorders = false;
            this.lblCountID.StylePriority.UseBorderWidth = false;
            this.lblCountID.StylePriority.UseFont = false;
            this.lblCountID.StylePriority.UsePadding = false;
            this.lblCountID.StylePriority.UseTextAlignment = false;
            this.lblCountID.Text = "Count ID:";
            this.lblCountID.TextAlignment = DevExpress.XtraPrinting.TextAlignment.TopLeft;
            // 
            // lblCountDesc
            // 
            this.lblCountDesc.BackColor = System.Drawing.Color.Gainsboro;
            this.lblCountDesc.BorderColor = System.Drawing.Color.DimGray;
            this.lblCountDesc.Borders = ((DevExpress.XtraPrinting.BorderSide)(((DevExpress.XtraPrinting.BorderSide.Left | DevExpress.XtraPrinting.BorderSide.Right) 
            | DevExpress.XtraPrinting.BorderSide.Bottom)));
            this.lblCountDesc.BorderWidth = 2F;
            this.lblCountDesc.Dpi = 254F;
            this.lblCountDesc.Font = new System.Drawing.Font("Arial", 9F, System.Drawing.FontStyle.Bold);
            this.lblCountDesc.LocationFloat = new DevExpress.Utils.PointFloat(0F, 228.4109F);
            this.lblCountDesc.Name = "lblCountDesc";
            this.lblCountDesc.Padding = new DevExpress.XtraPrinting.PaddingInfo(11, 11, 11, 0, 254F);
            this.lblCountDesc.SizeF = new System.Drawing.SizeF(246.38F, 98.11F);
            this.lblCountDesc.StylePriority.UseBackColor = false;
            this.lblCountDesc.StylePriority.UseBorderColor = false;
            this.lblCountDesc.StylePriority.UseBorders = false;
            this.lblCountDesc.StylePriority.UseBorderWidth = false;
            this.lblCountDesc.StylePriority.UseFont = false;
            this.lblCountDesc.StylePriority.UsePadding = false;
            this.lblCountDesc.StylePriority.UseTextAlignment = false;
            this.lblCountDesc.Text = "Count Description:";
            this.lblCountDesc.TextAlignment = DevExpress.XtraPrinting.TextAlignment.TopLeft;
            // 
            // barCodeCountNo
            // 
            this.barCodeCountNo.AutoModule = true;
            this.barCodeCountNo.DataBindings.AddRange(new DevExpress.XtraReports.UI.XRBinding[] {
            new DevExpress.XtraReports.UI.XRBinding("Text", null, "uspICReportPhysicalInventoryCount.strCountNo")});
            this.barCodeCountNo.Dpi = 254F;
            this.barCodeCountNo.LocationFloat = new DevExpress.Utils.PointFloat(1254.145F, 150.7292F);
            this.barCodeCountNo.Module = 5.08F;
            this.barCodeCountNo.Name = "barCodeCountNo";
            this.barCodeCountNo.Padding = new DevExpress.XtraPrinting.PaddingInfo(25, 25, 0, 0, 254F);
            this.barCodeCountNo.ShowText = false;
            this.barCodeCountNo.SizeF = new System.Drawing.SizeF(695.855F, 138.5358F);
            this.barCodeCountNo.StylePriority.UseTextAlignment = false;
            this.barCodeCountNo.Symbology = code128Generator1;
            this.barCodeCountNo.TextAlignment = DevExpress.XtraPrinting.TextAlignment.BottomCenter;
            // 
            // lblDate
            // 
            this.lblDate.BackColor = System.Drawing.Color.Gainsboro;
            this.lblDate.BorderColor = System.Drawing.Color.DimGray;
            this.lblDate.Borders = ((DevExpress.XtraPrinting.BorderSide)((((DevExpress.XtraPrinting.BorderSide.Left | DevExpress.XtraPrinting.BorderSide.Top) 
            | DevExpress.XtraPrinting.BorderSide.Right) 
            | DevExpress.XtraPrinting.BorderSide.Bottom)));
            this.lblDate.BorderWidth = 2F;
            this.lblDate.Dpi = 254F;
            this.lblDate.Font = new System.Drawing.Font("Arial", 9F, System.Drawing.FontStyle.Bold);
            this.lblDate.LocationFloat = new DevExpress.Utils.PointFloat(0F, 150.7292F);
            this.lblDate.Name = "lblDate";
            this.lblDate.Padding = new DevExpress.XtraPrinting.PaddingInfo(11, 11, 11, 0, 254F);
            this.lblDate.SizeF = new System.Drawing.SizeF(246.38F, 77.68175F);
            this.lblDate.StylePriority.UseBackColor = false;
            this.lblDate.StylePriority.UseBorderColor = false;
            this.lblDate.StylePriority.UseBorders = false;
            this.lblDate.StylePriority.UseBorderWidth = false;
            this.lblDate.StylePriority.UseFont = false;
            this.lblDate.StylePriority.UsePadding = false;
            this.lblDate.StylePriority.UseTextAlignment = false;
            this.lblDate.Text = "Date:";
            this.lblDate.TextAlignment = DevExpress.XtraPrinting.TextAlignment.TopLeft;
            // 
            // xrLabel17
            // 
            this.xrLabel17.Dpi = 254F;
            this.xrLabel17.Font = new System.Drawing.Font("Arial", 18F, System.Drawing.FontStyle.Bold);
            this.xrLabel17.ForeColor = System.Drawing.Color.Black;
            this.xrLabel17.LocationFloat = new DevExpress.Utils.PointFloat(0F, 0F);
            this.xrLabel17.Name = "xrLabel17";
            this.xrLabel17.Padding = new DevExpress.XtraPrinting.PaddingInfo(5, 5, 0, 0, 254F);
            this.xrLabel17.SizeF = new System.Drawing.SizeF(1950F, 83.82F);
            this.xrLabel17.StylePriority.UseFont = false;
            this.xrLabel17.StylePriority.UseForeColor = false;
            this.xrLabel17.StylePriority.UseTextAlignment = false;
            this.xrLabel17.Text = "PHYSICAL INVENTORY COUNT";
            this.xrLabel17.TextAlignment = DevExpress.XtraPrinting.TextAlignment.TopCenter;
            // 
            // PageFooter
            // 
            this.PageFooter.Controls.AddRange(new DevExpress.XtraReports.UI.XRControl[] {
            this.xrPageInfo2});
            this.PageFooter.Dpi = 254F;
            this.PageFooter.HeightF = 116.6283F;
            this.PageFooter.Name = "PageFooter";
            // 
            // xrPageInfo2
            // 
            this.xrPageInfo2.Dpi = 254F;
            this.xrPageInfo2.Font = new System.Drawing.Font("Arial", 7F, System.Drawing.FontStyle.Italic);
            this.xrPageInfo2.Format = "Page {0} of {1}";
            this.xrPageInfo2.LocationFloat = new DevExpress.Utils.PointFloat(1139.74F, 0F);
            this.xrPageInfo2.Name = "xrPageInfo2";
            this.xrPageInfo2.Padding = new DevExpress.XtraPrinting.PaddingInfo(5, 5, 0, 0, 254F);
            this.xrPageInfo2.SizeF = new System.Drawing.SizeF(810.2601F, 58.42F);
            this.xrPageInfo2.StylePriority.UseFont = false;
            this.xrPageInfo2.StylePriority.UseTextAlignment = false;
            this.xrPageInfo2.TextAlignment = DevExpress.XtraPrinting.TextAlignment.MiddleRight;
            // 
            // sqlDataSource1
            // 
            this.sqlDataSource1.ConnectionName = "";
            msSqlConnectionParameters1.AuthorizationType = DevExpress.DataAccess.ConnectionParameters.MsSqlAuthorizationType.SqlServer;
            msSqlConnectionParameters1.DatabaseName = "";
            msSqlConnectionParameters1.ServerName = "";
            this.sqlDataSource1.ConnectionParameters = msSqlConnectionParameters1;
            this.sqlDataSource1.Name = "sqlDataSource1";
            storedProcQuery1.Name = "uspICReportPhysicalInventoryCount";
            queryParameter1.Name = "@xmlParam";
            queryParameter1.Type = typeof(string);
            storedProcQuery1.Parameters.Add(queryParameter1);
            storedProcQuery1.StoredProcName = "uspICReportPhysicalInventoryCount";
            this.sqlDataSource1.Queries.AddRange(new DevExpress.DataAccess.Sql.SqlQuery[] {
            storedProcQuery1});
            this.sqlDataSource1.ResultSchemaSerializable = resources.GetString("sqlDataSource1.ResultSchemaSerializable");
            // 
            // GroupHeader1
            // 
            this.GroupHeader1.Controls.AddRange(new DevExpress.XtraReports.UI.XRControl[] {
            this.xrLabel1});
            this.GroupHeader1.Dpi = 254F;
            this.GroupHeader1.GroupFields.AddRange(new DevExpress.XtraReports.UI.GroupField[] {
            new DevExpress.XtraReports.UI.GroupField("strSubLocationName", DevExpress.XtraReports.UI.XRColumnSortOrder.Ascending)});
            this.GroupHeader1.HeightF = 58.42F;
            this.GroupHeader1.KeepTogether = true;
            this.GroupHeader1.Level = 1;
            this.GroupHeader1.Name = "GroupHeader1";
            this.GroupHeader1.PageBreak = DevExpress.XtraReports.UI.PageBreak.BeforeBand;
            // 
            // xrLabel1
            // 
            this.xrLabel1.DataBindings.AddRange(new DevExpress.XtraReports.UI.XRBinding[] {
            new DevExpress.XtraReports.UI.XRBinding("Text", null, "uspICReportPhysicalInventoryCount.strSubLocationName")});
            this.xrLabel1.Dpi = 254F;
            this.xrLabel1.LocationFloat = new DevExpress.Utils.PointFloat(0F, 0F);
            this.xrLabel1.Name = "xrLabel1";
            this.xrLabel1.Padding = new DevExpress.XtraPrinting.PaddingInfo(5, 5, 0, 0, 254F);
            this.xrLabel1.SizeF = new System.Drawing.SizeF(254F, 58.42F);
            this.xrLabel1.Text = "xrLabel1";
            this.xrLabel1.Visible = false;
            // 
            // GroupHeader2
            // 
            this.GroupHeader2.Controls.AddRange(new DevExpress.XtraReports.UI.XRControl[] {
            this.xrLabel2});
            this.GroupHeader2.Dpi = 254F;
            this.GroupHeader2.GroupFields.AddRange(new DevExpress.XtraReports.UI.GroupField[] {
            new DevExpress.XtraReports.UI.GroupField("strStorageLocationName", DevExpress.XtraReports.UI.XRColumnSortOrder.Ascending)});
            this.GroupHeader2.HeightF = 63.5F;
            this.GroupHeader2.KeepTogether = true;
            this.GroupHeader2.Name = "GroupHeader2";
            this.GroupHeader2.PageBreak = DevExpress.XtraReports.UI.PageBreak.BeforeBand;
            // 
            // xrLabel2
            // 
            this.xrLabel2.DataBindings.AddRange(new DevExpress.XtraReports.UI.XRBinding[] {
            new DevExpress.XtraReports.UI.XRBinding("Text", null, "uspICReportPhysicalInventoryCount.strStorageLocationName")});
            this.xrLabel2.Dpi = 254F;
            this.xrLabel2.LocationFloat = new DevExpress.Utils.PointFloat(0F, 0F);
            this.xrLabel2.Name = "xrLabel2";
            this.xrLabel2.Padding = new DevExpress.XtraPrinting.PaddingInfo(5, 5, 0, 0, 254F);
            this.xrLabel2.SizeF = new System.Drawing.SizeF(254F, 58.42F);
            this.xrLabel2.Text = "xrLabel2";
            this.xrLabel2.Visible = false;
            // 
            // xrLabel3
            // 
            this.xrLabel3.BackColor = System.Drawing.Color.Gainsboro;
            this.xrLabel3.BorderColor = System.Drawing.Color.DimGray;
            this.xrLabel3.Borders = ((DevExpress.XtraPrinting.BorderSide)(((DevExpress.XtraPrinting.BorderSide.Left | DevExpress.XtraPrinting.BorderSide.Right) 
            | DevExpress.XtraPrinting.BorderSide.Bottom)));
            this.xrLabel3.BorderWidth = 2F;
            this.xrLabel3.Dpi = 254F;
            this.xrLabel3.Font = new System.Drawing.Font("Arial", 9F, System.Drawing.FontStyle.Bold);
            this.xrLabel3.LocationFloat = new DevExpress.Utils.PointFloat(0F, 326.5209F);
            this.xrLabel3.Name = "xrLabel3";
            this.xrLabel3.Padding = new DevExpress.XtraPrinting.PaddingInfo(11, 11, 11, 0, 254F);
            this.xrLabel3.SizeF = new System.Drawing.SizeF(246.38F, 98.10745F);
            this.xrLabel3.StylePriority.UseBackColor = false;
            this.xrLabel3.StylePriority.UseBorderColor = false;
            this.xrLabel3.StylePriority.UseBorders = false;
            this.xrLabel3.StylePriority.UseBorderWidth = false;
            this.xrLabel3.StylePriority.UseFont = false;
            this.xrLabel3.StylePriority.UsePadding = false;
            this.xrLabel3.StylePriority.UseTextAlignment = false;
            this.xrLabel3.Text = "Location:";
            this.xrLabel3.TextAlignment = DevExpress.XtraPrinting.TextAlignment.TopLeft;
            // 
            // xrLabel4
            // 
            this.xrLabel4.BorderColor = System.Drawing.Color.DimGray;
            this.xrLabel4.Borders = ((DevExpress.XtraPrinting.BorderSide)((DevExpress.XtraPrinting.BorderSide.Right | DevExpress.XtraPrinting.BorderSide.Bottom)));
            this.xrLabel4.BorderWidth = 2F;
            this.xrLabel4.DataBindings.AddRange(new DevExpress.XtraReports.UI.XRBinding[] {
            new DevExpress.XtraReports.UI.XRBinding("Text", null, "uspICReportPhysicalInventoryCount.strLocationName")});
            this.xrLabel4.Dpi = 254F;
            this.xrLabel4.Font = new System.Drawing.Font("Arial", 9F);
            this.xrLabel4.LocationFloat = new DevExpress.Utils.PointFloat(246.38F, 326.5209F);
            this.xrLabel4.Name = "xrLabel4";
            this.xrLabel4.Padding = new DevExpress.XtraPrinting.PaddingInfo(11, 11, 11, 0, 254F);
            this.xrLabel4.SizeF = new System.Drawing.SizeF(701.1458F, 98.10745F);
            this.xrLabel4.StylePriority.UseBorderColor = false;
            this.xrLabel4.StylePriority.UseBorders = false;
            this.xrLabel4.StylePriority.UseBorderWidth = false;
            this.xrLabel4.StylePriority.UseFont = false;
            this.xrLabel4.StylePriority.UsePadding = false;
            this.xrLabel4.Text = "xrLabel4";
            // 
            // xrLabel5
            // 
            this.xrLabel5.BackColor = System.Drawing.Color.Gainsboro;
            this.xrLabel5.BorderColor = System.Drawing.Color.DimGray;
            this.xrLabel5.Borders = ((DevExpress.XtraPrinting.BorderSide)(((DevExpress.XtraPrinting.BorderSide.Left | DevExpress.XtraPrinting.BorderSide.Right) 
            | DevExpress.XtraPrinting.BorderSide.Bottom)));
            this.xrLabel5.BorderWidth = 2F;
            this.xrLabel5.Dpi = 254F;
            this.xrLabel5.Font = new System.Drawing.Font("Arial", 9F, System.Drawing.FontStyle.Bold);
            this.xrLabel5.LocationFloat = new DevExpress.Utils.PointFloat(0F, 424.6284F);
            this.xrLabel5.Name = "xrLabel5";
            this.xrLabel5.Padding = new DevExpress.XtraPrinting.PaddingInfo(11, 11, 11, 0, 254F);
            this.xrLabel5.SizeF = new System.Drawing.SizeF(246.38F, 98.10745F);
            this.xrLabel5.StylePriority.UseBackColor = false;
            this.xrLabel5.StylePriority.UseBorderColor = false;
            this.xrLabel5.StylePriority.UseBorders = false;
            this.xrLabel5.StylePriority.UseBorderWidth = false;
            this.xrLabel5.StylePriority.UseFont = false;
            this.xrLabel5.StylePriority.UsePadding = false;
            this.xrLabel5.StylePriority.UseTextAlignment = false;
            this.xrLabel5.Text = "Storage Unit:";
            this.xrLabel5.TextAlignment = DevExpress.XtraPrinting.TextAlignment.TopLeft;
            // 
            // xrLabel6
            // 
            this.xrLabel6.BorderColor = System.Drawing.Color.DimGray;
            this.xrLabel6.Borders = ((DevExpress.XtraPrinting.BorderSide)((DevExpress.XtraPrinting.BorderSide.Right | DevExpress.XtraPrinting.BorderSide.Bottom)));
            this.xrLabel6.BorderWidth = 2F;
            this.xrLabel6.DataBindings.AddRange(new DevExpress.XtraReports.UI.XRBinding[] {
            new DevExpress.XtraReports.UI.XRBinding("Text", null, "uspICReportPhysicalInventoryCount.strSubLocationName")});
            this.xrLabel6.Dpi = 254F;
            this.xrLabel6.Font = new System.Drawing.Font("Arial", 9F);
            this.xrLabel6.LocationFloat = new DevExpress.Utils.PointFloat(246.38F, 424.6284F);
            this.xrLabel6.Name = "xrLabel6";
            this.xrLabel6.Padding = new DevExpress.XtraPrinting.PaddingInfo(11, 11, 11, 0, 254F);
            this.xrLabel6.SizeF = new System.Drawing.SizeF(701.1458F, 98.10745F);
            this.xrLabel6.StylePriority.UseBorderColor = false;
            this.xrLabel6.StylePriority.UseBorders = false;
            this.xrLabel6.StylePriority.UseBorderWidth = false;
            this.xrLabel6.StylePriority.UseFont = false;
            this.xrLabel6.StylePriority.UsePadding = false;
            this.xrLabel6.Text = "xrLabel6";
            // 
            // PhysicalInventoryCount
            // 
            this.Bands.AddRange(new DevExpress.XtraReports.UI.Band[] {
            this.Detail,
            this.TopMargin,
            this.BottomMargin,
            this.PageHeader,
            this.PageFooter,
            this.GroupHeader1,
            this.GroupHeader2});
            this.ComponentStorage.AddRange(new System.ComponentModel.IComponent[] {
            this.sqlDataSource1});
            this.DataMember = "uspICReportPhysicalInventoryCount";
            this.DataSource = this.sqlDataSource1;
            this.DefaultPrinterSettingsUsing.UseLandscape = true;
            this.Dpi = 254F;
            this.Margins = new System.Drawing.Printing.Margins(101, 108, 93, 92);
            this.PageHeight = 2794;
            this.PageWidth = 2159;
            this.ReportUnit = DevExpress.XtraReports.UI.ReportUnit.TenthsOfAMillimeter;
            this.Version = "15.1";
            ((System.ComponentModel.ISupportInitialize)(this.xrTable3)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.xrTable1)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.xpDataView1)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.xpDataView2)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.xpDataView3)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this)).EndInit();

        }

        #endregion

        private DevExpress.XtraReports.UI.DetailBand Detail;
        private DevExpress.XtraReports.UI.TopMarginBand TopMargin;
        private DevExpress.XtraReports.UI.BottomMarginBand BottomMargin;
        private DevExpress.XtraReports.UI.PageHeaderBand PageHeader;
        private DevExpress.XtraReports.UI.PageFooterBand PageFooter;
        private DevExpress.XtraReports.UI.XRLabel xrLabel17;
        private DevExpress.XtraReports.UI.XRLabel lblDate;
        private DevExpress.XtraReports.UI.XRBarCode barCodeCountNo;
        private DevExpress.XtraReports.UI.XRLabel lblCountID;
        private DevExpress.XtraReports.UI.XRPageInfo xrPageInfo2;
        private DevExpress.XtraReports.UI.XRLabel valueCountDate;
        private DevExpress.DataAccess.Sql.SqlDataSource sqlDataSource1;
        private DevExpress.XtraReports.UI.XRLabel valueCountNo;
        private DevExpress.XtraReports.UI.XRLabel valueCountDesc;
        private DevExpress.XtraReports.UI.XRLabel lblCountDesc;
        private DevExpress.Xpo.XPDataView xpDataView1;
        private DevExpress.Xpo.XPDataView xpDataView2;
        private DevExpress.Xpo.XPDataView xpDataView3;
        private DevExpress.XtraReports.UI.XRTable xrTable3;
        private DevExpress.XtraReports.UI.XRTableRow xrTableRow3;
        private DevExpress.XtraReports.UI.XRTableCell valueCountLineNo;
        private DevExpress.XtraReports.UI.XRTableCell valueItemNo;
        private DevExpress.XtraReports.UI.XRTableCell valueDesc;
        private DevExpress.XtraReports.UI.XRTableCell valueStorageLocation;
        private DevExpress.XtraReports.UI.XRTableCell valueLotID;
        private DevExpress.XtraReports.UI.XRTableCell valueUnitOfMeasure;
        private DevExpress.XtraReports.UI.XRTableCell valueNoOfPallets;
        private DevExpress.XtraReports.UI.XRTableCell valueQtyPerPallet;
        private DevExpress.XtraReports.UI.XRTableCell valuePhysicalCount;
        private DevExpress.XtraReports.UI.XRTable xrTable1;
        private DevExpress.XtraReports.UI.XRTableRow xrTableRow1;
        private DevExpress.XtraReports.UI.XRTableCell lblCountLineNo;
        private DevExpress.XtraReports.UI.XRTableCell lblItemNo;
        private DevExpress.XtraReports.UI.XRTableCell lblDesc;
        private DevExpress.XtraReports.UI.XRTableCell lblStorageLocation;
        private DevExpress.XtraReports.UI.XRTableCell lblLotID;
        private DevExpress.XtraReports.UI.XRTableCell lblUnitOfMeasure;
        private DevExpress.XtraReports.UI.XRTableCell lblQtyPerPallet;
        private DevExpress.XtraReports.UI.XRTableCell lblPhysicalCount;
        private DevExpress.XtraReports.UI.XRLabel valScannedCountEntry;
        private DevExpress.XtraReports.UI.XRLabel valCountByPallets;
        private DevExpress.XtraReports.UI.XRLabel valCountByLots;
        private DevExpress.XtraReports.UI.XRTableCell lblNoOfPallets;
        private DevExpress.XtraReports.UI.XRLabel lblCountID2;
        private DevExpress.XtraReports.UI.XRLabel valueCountNo2;
        private DevExpress.XtraReports.UI.GroupHeaderBand GroupHeader1;
        private DevExpress.XtraReports.UI.XRLabel xrLabel1;
        private DevExpress.XtraReports.UI.GroupHeaderBand GroupHeader2;
        private DevExpress.XtraReports.UI.XRLabel xrLabel2;
        private DevExpress.XtraReports.UI.XRLabel xrLabel6;
        private DevExpress.XtraReports.UI.XRLabel xrLabel5;
        private DevExpress.XtraReports.UI.XRLabel xrLabel4;
        private DevExpress.XtraReports.UI.XRLabel xrLabel3;
    }
}
