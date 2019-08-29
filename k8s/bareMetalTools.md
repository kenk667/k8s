With the new order from Easy to pivot to open source K8, there is less reason to justify the need for VMware as a middle layer. There are more advantages to bare metal K8s;

- No middle layer IaaS complexity
- No NSX complexity
- No loss of bare metal accelerators through hypervisor (hyperthreading, GPU, etc)
- Easier underlying IaaS manageability
- Lowered licensing cost with the elimination of VMW
- etc, etc, ad nauseum

With bare metal comes new methods to support deployment and like to keep the devops ethos of infrastructure as code. This changes the stack completely and potentials are;

- MaaS (https://maas.io/)
- Foreman (https://www.theforeman.org/)
- RackHD (https://github.com/RackHD/RackHD)
- Spinnaker (https://www.spinnaker.io/)
- K8s-tew (https://github.com/darxkies/k8s-tew)
- Digital ReBar (https://github.com/digitalrebar/provision)