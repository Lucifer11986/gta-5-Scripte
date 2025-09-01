const app = new Vue({
    el: '.app-container',
    data: {
        screen: 'dashboard',
        societyInfo: { job: "autobauer", label: "Autobauer GmbH", money: 100000 },
        employee: [],
        grades: [],
        materials: [],
        vehicleStorage: [],
        productionQueue: [],
        orders: [],
        vehiclePrices: [],
        currentTime: "",
        employe_name: '',
        grade_name: '',
        newEmployee: { fullName: '', gradeName: '' },
        selectedProductionVehicle: '',
        customPrice: '',
        tabs: [
            { screen: 'dashboard', label: 'Dashboard', icon: '📊' },
            { screen: 'vehicles', label: 'Fahrzeuge', icon: '🚗' },
            { screen: 'materials', label: 'Materialien', icon: '⚙️' },
            { screen: 'storage', label: 'Lager', icon: '📦' },
            { screen: 'production', label: 'Produktion', icon: '🏭' },
            { screen: 'orders', label: 'Bestellungen', icon: '📝' },
            { screen: 'prices', label: 'Preise', icon: '💲' },
            { screen: 'employee', label: 'Mitarbeiter', icon: '👷' },
            { screen: 'grades', label: 'Ränge', icon: '🎖️' }
        ],
        notify: { enable: false, message: '' },
        neonInterval: null
    },
    mounted() {
        this.startNeonEffect();

        // UI standardmäßig verstecken
        this.hideUI();

        // NUI Event Listener
        window.addEventListener('message', (event) => {
            const data = event.data;
            switch(data.action) {
                case 'openBossMenu':
                    this.screen = 'dashboard';
                    this.showUI();
                    break;
                case 'closeMenu':
                    this.hideUI();
                    break;
                case 'setVehicles':
                    this.vehiclePrices = data.vehicles;
                    break;
                case 'updateProductionQueue':
                    this.productionQueue = data.queue;
                    break;
                case 'updateVehicleStorage':
                    this.vehicleStorage = data.storage;
                    break;
                case 'updateSocietyMoney':
                    this.societyInfo.money = data.money;
                    break;
                case 'loadEmployees':
                    this.employee = data.employees;
                    break;
                case 'loadMaterials':
                    this.materials = data.materials;
                    break;
                case 'loadGrades':
                    this.grades = data.grades;
                    break;
                case 'loadOrders':
                    this.orders = data.orders;
                    break;
            }
        });

        // direkt beim Laden Fahrzeuge vom Server anfordern
        fetch(`https://${GetParentResourceName()}/requestVehicles`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' }
        });
    },
    beforeDestroy() {
        clearInterval(this.neonInterval);
    },
    methods: {
        showUI() {
            document.querySelector('.app-container').style.display = 'flex';
        },
        hideUI() {
            document.querySelector('.app-container').style.display = 'none';
        },
        changeScreen(screen) {
            this.screen = screen;
            this.glowCards();
        },
        searchFromName() {
            return this.employe_name
                ? this.employee.filter(e => e.fullName.toLowerCase().includes(this.employe_name.toLowerCase()))
                : this.employee;
        },
        searchFromGrade() {
            return this.grade_name
                ? this.grades.filter(g => g.label.toLowerCase().includes(this.grade_name.toLowerCase()))
                : this.grades;
        },
        showNotification(message, duration = 3000) {
            this.notify.message = message;
            this.notify.enable = true;
            setTimeout(() => { this.notify.enable = false }, duration);
        },
        glowCards() {
            const cards = document.querySelectorAll('.card');
            cards.forEach(card => {
                card.style.transition = "all 0.5s ease-in-out";
                card.style.boxShadow = "0 0 25px #ff6b00, 0 0 35px #0ff inset";
                setTimeout(() => {
                    card.style.boxShadow = "0 0 15px #0ff, 0 0 20px #ff6b00 inset";
                }, 500);
            });
        },
        startNeonEffect() {
            const header = document.querySelector('.main-content h1');
            if (!header) return;
            this.neonInterval = setInterval(() => {
                header.style.textShadow = "0 0 12px #ff6b00, 0 0 20px #ff6b00, 0 0 30px #0ff";
                setTimeout(() => {
                    header.style.textShadow = "0 0 12px #ff6b00, 0 0 20px #0ff";
                }, 400);
            }, 2000);
        },
        hireEmployee() {
            if (!this.newEmployee.fullName || !this.newEmployee.gradeName) {
                this.showNotification("Bitte Name und Rang angeben!", 3000);
                return;
            }

            const today = new Date().toLocaleDateString("de-DE");
            const emp = { fullName: this.newEmployee.fullName, gradeName: this.newEmployee.gradeName, hireDate: today };

            fetch(`https://${GetParentResourceName()}/hireEmployee`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(emp)
            });

            this.employee.push({ identifier: Date.now(), ...emp, note: "Neu" });
            this.newEmployee.fullName = '';
            this.newEmployee.gradeName = '';
        },
        fireEmployee(empId) {
            const index = this.employee.findIndex(e => e.identifier === empId);
            if (index !== -1) this.employee.splice(index, 1);

            fetch(`https://${GetParentResourceName()}/fireEmployee`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ identifier: empId })
            });
        },
        startProduction() {
            if(!this.selectedProductionVehicle) {
                this.showNotification("Bitte ein Fahrzeug auswählen!", 3000);
                return;
            }

            const vehicle = this.vehiclePrices.find(v => v.model === this.selectedProductionVehicle);
            if(!vehicle) return;

            const price = this.customPrice ? parseInt(this.customPrice) : vehicle.price;

            fetch(`https://${GetParentResourceName()}/startProduction`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ vehicleName: vehicle.model, customPrice: price })
            });

            this.showNotification(`${vehicle.label || vehicle.model} wird produziert! Preis: ${price}$`, 3000);
            this.selectedProductionVehicle = '';
            this.customPrice = '';
        },
        deliverVehicle(vehicle) {
            if(vehicle.amount <= 0) return;
            fetch(`https://${GetParentResourceName()}/deliverVehicle`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ model: vehicle.model })
            });
        }
    },
    filters: {
        currency(value) {
            return value.toLocaleString("de-DE") + "€";
        }
    },
    computed: {
        vehiclesByCategory() {
            const categories = {};
            this.vehiclePrices.forEach(v => {
                if(!categories[v.category]) categories[v.category] = [];
                categories[v.category].push(v);
            });
            return categories;
        }
    }
});
