using System;
using System.Drawing;
using System.Collections;
using System.ComponentModel;
using DevExpress.XtraReports.UI;

namespace iRely.Inventory.WebApi.Reporting
{
    public partial class TransferOrderReport : DevExpress.XtraReports.UI.XtraReport
    {
        public TransferOrderReport()
        {
            InitializeComponent();
            xrTableCellQuantity.BeforePrint += xrTableCellQuantity_BeforePrint;
            xrTableCellNetWgt.BeforePrint += xrTableCellNetWgt_BeforePrint;
        }

        public void xrTableCellQuantity_BeforePrint(object sender, System.Drawing.Printing.PrintEventArgs e)
        {
            if (GetCurrentRow() == null) return;

            string quantity = GetCurrentColumnValue("dblQuantity") as string;
            string qtyUOM = GetCurrentColumnValue("strUnitMeasureSymbol") as string;

            ((XRTableCell)sender).Text += " " + qtyUOM;
        }

        public void xrTableCellNetWgt_BeforePrint(object sender, System.Drawing.Printing.PrintEventArgs e)
        {
            if (GetCurrentRow() == null) return;

            string netWgt = GetCurrentColumnValue("dblNet") as string;
            string netWgtUOM = GetCurrentColumnValue("strGrossNetUOMSymbol") as string;

            ((XRTableCell)sender).Text += " " + netWgtUOM;
        }
    }
}
