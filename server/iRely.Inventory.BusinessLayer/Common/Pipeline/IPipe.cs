using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace iRely.Inventory.BusinessLayer
{
    public interface IPipe<T>
    {
        T Execute(T input);
        void Register(IPipe<T> pipe);
    }
}
