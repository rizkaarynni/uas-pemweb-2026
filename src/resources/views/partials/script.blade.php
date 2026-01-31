 <script>
    //  Pricing Table
    const setup = () => {
      return {
        isNavOpen: false,

        billPlan: 'monthly',

        plans: [
          {
            name: 'Starter',
            price: {
              monthly: 29,
              annually: 29 * 12 - 199,
            },
            features: ['400 GB Storaget', 'Unlimited Photos & Videos', 'Exclusive Support'],
          },
          {
            name: 'Growth Plan',
            price: {
              monthly: 59,
              annually: 59 * 12 - 100,
            },
            features: ['400 GB Storaget', 'Unlimited Photos & Videos', 'Exclusive Support'],
          },
          {
            name: 'Business',
            price: {
              monthly: 139,
              annually: 139 * 12 - 100,
            },
            features: ['400 GB Storaget', 'Unlimited Photos & Videos', 'Exclusive Support'],
          },
        ],
      };
    };
  </script>
  <script defer src="{{ asset('asset-frontend/bundle.js') }}"></script>
