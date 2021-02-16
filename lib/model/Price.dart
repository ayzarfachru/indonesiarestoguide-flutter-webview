class Price{
  int original;
  int discounted;
  int delivery;

  Price(this.original, this.discounted, this.delivery);

  Price.original(this.original);

  Price.discounted(this.original, this.discounted);

  Price.delivery(this.original, this.delivery);
}