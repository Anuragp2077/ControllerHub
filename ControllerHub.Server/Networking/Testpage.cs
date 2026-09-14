namespace ControllerHub.Server.Networking;

public static class TestPage
{
    public const string Html = """
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta
    name="viewport"
    content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no"
>
<title>ControllerHub</title>

<style>
* {
    box-sizing: border-box;
    -webkit-tap-highlight-color: transparent;
}

html,
body {
    margin: 0;
    padding: 0;
    width: 100%;
    height: 100%;
    overflow: hidden;
    background: #111;
    color: white;
    font-family: Arial, sans-serif;
    touch-action: none;
    user-select: none;
}

body {
    display: flex;
    align-items: center;
    justify-content: center;
}

#app {
    width: 100%;
    height: 100%;
    max-width: 900px;
    display: flex;
    flex-direction: column;
}

#status {
    height: 42px;
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 8px;
    font-size: 14px;
    background: #181818;
    border-bottom: 1px solid #333;
}

.status-dot {
    width: 10px;
    height: 10px;
    border-radius: 50%;
    background: #777;
}

.status-dot.connected {
    background: #32d74b;
}

.status-dot.error {
    background: #ff453a;
}

#controller {
    flex: 1;
    display: grid;
    grid-template-columns: 1fr 1fr 1fr;
    grid-template-rows: 1fr 1fr;
    gap: 12px;
    padding: 14px;
    min-height: 0;
}

.panel {
    position: relative;
    min-width: 0;
    min-height: 0;
}

button {
    border: none;
    color: white;
    background: #292929;
    border-radius: 50%;
    font-weight: bold;
    touch-action: none;
}

button:active {
    transform: scale(0.94);
    background: #555;
}

.abxy {
    position: absolute;
    width: 54px;
    height: 54px;
    font-size: 18px;
}

#button-y {
    top: 4%;
    left: 50%;
    transform: translateX(-50%);
}

#button-x {
    top: 50%;
    left: 8%;
    transform: translateY(-50%);
}

#button-b {
    top: 50%;
    right: 8%;
    transform: translateY(-50%);
}

#button-a {
    bottom: 4%;
    left: 50%;
    transform: translateX(-50%);
}

#button-y:active,
#button-a:active {
    transform: translateX(-50%) scale(0.94);
}

#button-x:active,
#button-b:active {
    transform: translateY(-50%) scale(0.94);
}

.shoulders {
    position: absolute;
    top: 4px;
    left: 0;
    right: 0;
    display: flex;
    justify-content: space-between;
    gap: 8px;
}

.shoulder {
    width: 46%;
    height: 42px;
    border-radius: 12px;
    font-size: 14px;
}

.triggers {
    position: absolute;
    bottom: 4px;
    left: 0;
    right: 0;
    display: flex;
    justify-content: space-between;
    gap: 8px;
}

.trigger {
    width: 46%;
    height: 42px;
    border-radius: 12px;
    font-size: 14px;
}

.dpad {
    position: absolute;
    width: 150px;
    height: 150px;
    left: 50%;
    top: 50%;
    transform: translate(-50%, -50%);
}

.dpad button {
    position: absolute;
    width: 50px;
    height: 50px;
    border-radius: 10px;
    font-size: 20px;
}

#dpad-up {
    left: 50px;
    top: 0;
}

#dpad-down {
    left: 50px;
    bottom: 0;
}

#dpad-left {
    left: 0;
    top: 50px;
}

#dpad-right {
    right: 0;
    top: 50px;
}

.center-buttons {
    position: absolute;
    top: 50%;
    left: 50%;
    transform: translate(-50%, -50%);
    display: flex;
    gap: 10px;
}

.center-button {
    width: 58px;
    height: 38px;
    border-radius: 12px;
    font-size: 12px;
}

.stick-area {
    display: flex;
    align-items: center;
    justify-content: center;
}

.stick {
    width: min(42vw, 190px);
    height: min(42vw, 190px);
    max-width: 190px;
    max-height: 190px;
    border-radius: 50%;
    background: #202020;
    border: 2px solid #3d3d3d;
    position: relative;
}

.stick-knob {
    position: absolute;
    width: 44%;
    height: 44%;
    left: 28%;
    top: 28%;
    border-radius: 50%;
    background: #444;
    border: 2px solid #666;
    transition: transform 0.03s linear;
}

.stick-label {
    position: absolute;
    bottom: 8px;
    width: 100%;
    text-align: center;
    font-size: 11px;
    color: #888;
}

#connection-overlay {
    position: fixed;
    inset: 0;
    display: none;
    align-items: center;
    justify-content: center;
    background: rgba(0, 0, 0, 0.9);
    z-index: 100;
    text-align: center;
    padding: 30px;
}

#connection-overlay.visible {
    display: flex;
}

.overlay-content {
    max-width: 360px;
}

.overlay-content h2 {
    margin-bottom: 10px;
}

.overlay-content p {
    color: #aaa;
    line-height: 1.5;
}

@media (max-width: 600px) {
    #controller {
        gap: 7px;
        padding: 8px;
    }

    .abxy {
        width: 46px;
        height: 46px;
        font-size: 16px;
    }

    .dpad {
        width: 125px;
        height: 125px;
    }

    .dpad button {
        width: 42px;
        height: 42px;
    }

    #dpad-up {
        left: 41px;
    }

    #dpad-down {
        left: 41px;
    }

    #dpad-left {
        top: 41px;
    }

    #dpad-right {
        top: 41px;
    }

    .center-button {
        width: 50px;
        height: 34px;
    }
}
</style>
</head>

<body>

<div id="app">

    <div id="status">
        <span id="status-dot" class="status-dot"></span>
        <span id="status-text">Connecting...</span>
    </div>

    <div id="controller">

        <!-- LEFT SIDE -->

        <div class="panel">

            <div class="shoulders">
                <button
                    class="shoulder"
                    id="lb"
                    data-button="LeftBumper"
                >
                    LB
                </button>

                <button
                    class="shoulder"
                    id="rb"
                    data-button="RightBumper"
                >
                    RB
                </button>
            </div>

            <div class="stick-area" style="height:100%;">
                <div
                    class="stick"
                    id="left-stick"
                    data-stick="Left"
                >
                    <div
                        class="stick-knob"
                        id="left-knob"
                    ></div>

                    <div class="stick-label">
                        L3 • Double Tap
                    </div>
                </div>
            </div>

            <div class="triggers">
                <button
                    class="trigger"
                    id="lt"
                    data-trigger="Left"
                >
                    LT
                </button>

                <button
                    class="trigger"
                    id="rt"
                    data-trigger="Right"
                >
                    RT
                </button>
            </div>

        </div>

        <!-- CENTER -->

        <div class="panel">

            <div class="dpad">

                <button
                    id="dpad-up"
                    data-button="DPadUp"
                >
                    ▲
                </button>

                <button
                    id="dpad-down"
                    data-button="DPadDown"
                >
                    ▼
                </button>

                <button
                    id="dpad-left"
                    data-button="DPadLeft"
                >
                    ◀
                </button>

                <button
                    id="dpad-right"
                    data-button="DPadRight"
                >
                    ▶
                </button>

            </div>

            <div class="center-buttons">

                <button
                    class="center-button"
                    data-button="Back"
                >
                    BACK
                </button>

                <button
                    class="center-button"
                    data-button="Guide"
                >
                    GUIDE
                </button>

                <button
                    class="center-button"
                    data-button="Start"
                >
                    START
                </button>

            </div>

        </div>

        <!-- RIGHT SIDE -->

        <div class="panel">

            <button
                class="abxy"
                id="button-y"
                data-button="Y"
            >
                Y
            </button>

            <button
                class="abxy"
                id="button-x"
                data-button="X"
            >
                X
            </button>

            <button
                class="abxy"
                id="button-b"
                data-button="B"
            >
                B
            </button>

            <button
                class="abxy"
                id="button-a"
                data-button="A"
            >
                A
            </button>

            <div class="stick-area" style="height:100%;">
                <div
                    class="stick"
                    id="right-stick"
                    data-stick="Right"
                >
                    <div
                        class="stick-knob"
                        id="right-knob"
                    ></div>

                    <div class="stick-label">
                        R3 • Double Tap
                    </div>
                </div>
            </div>

        </div>

        <!-- BOTTOM LEFT -->

        <div class="panel">

            <div class="stick-area" style="height:100%;">
                <div
                    class="stick"
                    id="left-stick-secondary"
                    data-stick="Left"
                >
                    <div
                        class="stick-knob"
                        id="left-knob-secondary"
                    ></div>

                    <div class="stick-label">
                        LEFT STICK
                    </div>
                </div>
            </div>

        </div>

        <!-- BOTTOM CENTER -->

        <div class="panel">

            <div class="center-buttons">

                <button
                    class="center-button"
                    data-button="LeftStick"
                >
                    L3
                </button>

                <button
                    class="center-button"
                    data-button="RightStick"
                >
                    R3
                </button>

            </div>

        </div>

        <!-- BOTTOM RIGHT -->

        <div class="panel">

            <div class="stick-area" style="height:100%;">
                <div
                    class="stick"
                    id="right-stick-secondary"
                    data-stick="Right"
                >
                    <div
                        class="stick-knob"
                        id="right-knob-secondary"
                    ></div>

                    <div class="stick-label">
                        RIGHT STICK
                    </div>
                </div>
            </div>

        </div>

    </div>
</div>

<div id="connection-overlay">

    <div class="overlay-content">

        <h2 id="overlay-title">
            Connecting...
        </h2>

        <p id="overlay-message">
            Connecting to ControllerHub.
        </p>

    </div>

</div>

<script>

let socket = null;
let slotNumber = null;
let reconnectTimer = null;
let heartbeatTimer = null;

let connected = false;
let connecting = false;

const token =
    new URLSearchParams(
        window.location.search
    ).get("token");

const clientIdKey =
    "controllerhub-client-id";

let clientId =
    localStorage.getItem(
        clientIdKey
    );

if (!clientId) {

    if (
        window.crypto &&
        crypto.randomUUID
    ) {
        clientId =
            crypto.randomUUID();
    }
    else {
        clientId =
            Date.now().toString(36) +
            Math.random().toString(36).substring(2);
    }

    localStorage.setItem(
        clientIdKey,
        clientId
    );
}

const statusDot =
    document.getElementById(
        "status-dot"
    );

const statusText =
    document.getElementById(
        "status-text"
    );

const overlay =
    document.getElementById(
        "connection-overlay"
    );

const overlayTitle =
    document.getElementById(
        "overlay-title"
    );

const overlayMessage =
    document.getElementById(
        "overlay-message"
    );

function setStatus(
    text,
    state
) {
    statusText.textContent =
        text;

    statusDot.className =
        "status-dot " +
        (state || "");
}

function showOverlay(
    title,
    message
) {
    overlayTitle.textContent =
        title;

    overlayMessage.textContent =
        message;

    overlay.classList.add(
        "visible"
    );
}

function hideOverlay() {
    overlay.classList.remove(
        "visible"
    );
}

function connect() {

    if (connecting) {
        return;
    }

    connecting = true;

    if (!token) {

        connecting = false;

        setStatus(
            "Pairing token missing",
            "error"
        );

        showOverlay(
            "Pairing Required",
            "Open this controller using a valid ControllerHub QR code."
        );

        return;
    }

    setStatus(
        "Connecting...",
        ""
    );

    try {

        socket =
            new WebSocket(
                "ws://" +
                window.location.host +
                "/"
            );

        socket.addEventListener(
            "open",
            () => {

                connecting = false;

                const message = {
                    type: "connect",
                    version: 1,
                    clientId: clientId,
                    token: token
                };

                socket.send(
                    JSON.stringify(
                        message
                    )
                );
            }
        );

        socket.addEventListener(
            "message",
            event => {

                let message;

                try {
                    message =
                        JSON.parse(
                            event.data
                        );
                }
                catch {
                    return;
                }

                if (
                    message.type ===
                    "slot"
                ) {

                    slotNumber =
                        message.slot;

                    connected = true;

                    setStatus(
                        "Connected • Slot " +
                        slotNumber,
                        "connected"
                    );

                    hideOverlay();

                    startHeartbeat();

                    return;
                }

                if (
                    message.type ===
                    "error"
                ) {

                    connected = false;

                    setStatus(
                        message.message ||
                        "Connection rejected",
                        "error"
                    );

                    showOverlay(
                        "Connection Rejected",
                        message.message ||
                        "The server rejected this connection."
                    );

                    return;
                }
            }
        );

        socket.addEventListener(
            "close",
            () => {

                connecting = false;
                connected = false;
                slotNumber = null;

                stopHeartbeat();

                releaseAllInputs();

                setStatus(
                    "Disconnected",
                    "error"
                );

                showOverlay(
                    "Disconnected",
                    "Trying to reconnect..."
                );

                scheduleReconnect();
            }
        );

        socket.addEventListener(
            "error",
            () => {

                connecting = false;

                setStatus(
                    "Connection error",
                    "error"
                );
            }
        );

    }
    catch {

        connecting = false;

        setStatus(
            "Connection failed",
            "error"
        );

        scheduleReconnect();
    }
}

function scheduleReconnect() {

    if (reconnectTimer) {
        return;
    }

    reconnectTimer =
        setTimeout(
            () => {

                reconnectTimer = null;

                connect();

            },
            2000
        );
}

function startHeartbeat() {

    stopHeartbeat();

    heartbeatTimer =
        setInterval(
            () => {

                if (
                    socket &&
                    socket.readyState ===
                    WebSocket.OPEN &&
                    connected
                ) {

                    socket.send(
                        JSON.stringify({
                            type:
                                "heartbeat",
                            version: 1,
                            clientId:
                                clientId
                        })
                    );
                }

            },
            2000
        );
}

function stopHeartbeat() {

    if (heartbeatTimer) {

        clearInterval(
            heartbeatTimer
        );

        heartbeatTimer = null;
    }
}

function send(message) {

    if (
        !connected ||
        !socket ||
        socket.readyState !==
        WebSocket.OPEN
    ) {
        return;
    }

    message.version = 1;
    message.clientId = clientId;

    socket.send(
        JSON.stringify(message)
    );
}

function sendButton(
    button,
    pressed
) {

    send({
        type: "button",
        button: button,
        pressed: pressed
    });
}

function sendStick(
    stick,
    x,
    y
) {

    send({
        type: "stick",
        stick: stick,
        x: x,
        y: y
    });
}

function sendTrigger(
    trigger,
    value
) {

    send({
        type: "trigger",
        trigger: trigger,
        value: value
    });
}

const activeButtons =
    new Set();

function releaseAllInputs() {

    for (
        const button
        of activeButtons
    ) {

        sendButton(
            button,
            false
        );
    }

    activeButtons.clear();

    sendStick(
        "Left",
        0,
        0
    );

    sendStick(
        "Right",
        0,
        0
    );

    sendTrigger(
        "Left",
        0
    );

    sendTrigger(
        "Right",
        0
    );
}

document
    .querySelectorAll(
        "[data-button]"
    )
    .forEach(
        button => {

            const name =
                button.dataset.button;

            button.addEventListener(
                "pointerdown",
                event => {

                    event.preventDefault();

                    button.setPointerCapture(
                        event.pointerId
                    );

                    if (
                        activeButtons.has(
                            name
                        )
                    ) {
                        return;
                    }

                    activeButtons.add(
                        name
                    );

                    sendButton(
                        name,
                        true
                    );
                }
            );

            button.addEventListener(
                "pointerup",
                event => {

                    event.preventDefault();

                    activeButtons.delete(
                        name
                    );

                    sendButton(
                        name,
                        false
                    );
                }
            );

            button.addEventListener(
                "pointercancel",
                () => {

                    activeButtons.delete(
                        name
                    );

                    sendButton(
                        name,
                        false
                    );
                }
            );
        }
    );

document
    .querySelectorAll(
        "[data-trigger]"
    )
    .forEach(
        button => {

            const name =
                button.dataset.trigger;

            button.addEventListener(
                "pointerdown",
                event => {

                    event.preventDefault();

                    button.setPointerCapture(
                        event.pointerId
                    );

                    sendTrigger(
                        name,
                        1
                    );
                }
            );

            button.addEventListener(
                "pointerup",
                event => {

                    event.preventDefault();

                    sendTrigger(
                        name,
                        0
                    );
                }
            );

            button.addEventListener(
                "pointercancel",
                () => {

                    sendTrigger(
                        name,
                        0
                    );
                }
            );
        }
    );

function setupStick(
    stickElement,
    knobElement,
    stickName
) {

    let activePointer = null;

    function update(
        clientX,
        clientY
    ) {

        const rect =
            stickElement.getBoundingClientRect();

        const centerX =
            rect.left +
            rect.width / 2;

        const centerY =
            rect.top +
            rect.height / 2;

        const radius =
            rect.width / 2;

        let dx =
            clientX -
            centerX;

        let dy =
            clientY -
            centerY;

        const distance =
            Math.sqrt(
                dx * dx +
                dy * dy
            );

        if (
            distance > radius
        ) {

            const scale =
                radius / distance;

            dx *= scale;
            dy *= scale;
        }

        const x =
            Math.max(
                -1,
                Math.min(
                    1,
                    dx / radius
                )
            );

        const y =
            Math.max(
                -1,
                Math.min(
                    1,
                    dy / radius
                )
            );

        const maxMove =
            rect.width * 0.28;

        knobElement.style.transform =
            "translate(" +
            (x * maxMove) +
            "px, " +
            (y * maxMove) +
            "px)";

        sendStick(
            stickName,
            x,
            -y
        );
    }

    function reset() {

        activePointer = null;

        knobElement.style.transform =
            "translate(0px, 0px)";

        sendStick(
            stickName,
            0,
            0
        );
    }

    stickElement.addEventListener(
        "pointerdown",
        event => {

            event.preventDefault();

            activePointer =
                event.pointerId;

            stickElement.setPointerCapture(
                event.pointerId
            );

            update(
                event.clientX,
                event.clientY
            );
        }
    );

    stickElement.addEventListener(
        "pointermove",
        event => {

            if (
                event.pointerId !==
                activePointer
            ) {
                return;
            }

            event.preventDefault();

            update(
                event.clientX,
                event.clientY
            );
        }
    );

    stickElement.addEventListener(
        "pointerup",
        event => {

            if (
                event.pointerId ===
                activePointer
            ) {
                reset();
            }
        }
    );

    stickElement.addEventListener(
        "pointercancel",
        event => {

            if (
                event.pointerId ===
                activePointer
            ) {
                reset();
            }
        }
    );
}

setupStick(
    document.getElementById(
        "left-stick"
    ),
    document.getElementById(
        "left-knob"
    ),
    "Left"
);

setupStick(
    document.getElementById(
        "right-stick"
    ),
    document.getElementById(
        "right-knob"
    ),
    "Right"
);

setupStick(
    document.getElementById(
        "left-stick-secondary"
    ),
    document.getElementById(
        "left-knob-secondary"
    ),
    "Left"
);

setupStick(
    document.getElementById(
        "right-stick-secondary"
    ),
    document.getElementById(
        "right-knob-secondary"
    ),
    "Right"
);

document.addEventListener(
    "visibilitychange",
    () => {

        if (
            document.visibilityState ===
            "hidden"
        ) {
            releaseAllInputs();
        }
    }
);

window.addEventListener(
    "pagehide",
    () => {

        releaseAllInputs();

        stopHeartbeat();

        if (socket) {
            socket.close();
        }
    }
);

connect();

</script>

</body>
</html>
""";
}