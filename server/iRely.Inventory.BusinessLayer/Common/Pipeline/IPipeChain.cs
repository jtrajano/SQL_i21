namespace iRely.Inventory.BusinessLayer
{
    public interface IPipeChain<T>
    {
        void Execute(T input);
        IPipeChain<T> Register(IPipe<T> pipe);
    }
}