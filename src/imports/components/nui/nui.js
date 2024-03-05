const resourceName = GetParentResourceName();

class nuiResourceListener {
    eventname;
    listener;

    constructor(eventname, listener) {
        if (typeof eventname !== "string")
            throw new Error("eventname must be a string");
        if (typeof listener !== "function")
            throw new Error("listener must be a function");

        this.eventname = eventname;
        this.listener = (event) => {
            const data = event.data;
            if (data.action !== this.eventname) return;
            listener(...(data.args || []));
        };

        window.addEventListener("message", this.listener);
    }

    destroy() {
        if (!this.listener) return;
        window.removeEventListener("message", this.listener);
    }
}

class nui {
    static register(eventname, listener) {
        return new nuiResourceListener(eventname, listener);
    }

    static emit(eventname, ...args) {
        fetch(`https://${resourceName}/${eventname}`, {
            method: "POST",
            headers: {
                "Content-Type": "application/json; charset=UTF-8",
            },
            body: JSON.stringify(args),
        });
    }

    static destroy(listener) {
        if (!listener) return;
        listener.destroy();
    }
}

cslib = { nui: nui }