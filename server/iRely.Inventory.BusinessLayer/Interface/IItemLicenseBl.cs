using iRely.Common;
using iRely.Inventory.Model;
using System.Threading.Tasks;

namespace iRely.Inventory.BusinessLayer
{
    public interface IItemLicenseBl : IBusinessLayer<tblICItemLicense>
    {
        Task<GetObjectResult> GetItemLicense(GetParameter param);
    }
}
