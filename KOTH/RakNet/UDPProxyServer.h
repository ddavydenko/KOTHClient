/// \file
/// \brief A RakNet plugin performing networking to communicate with UDPProxyServer. It allows UDPProxyServer to control our instance of UDPForwarder.
///
/// This file is part of RakNet Copyright 2003 Jenkins Software LLC
///
/// Usage of RakNet is subject to the appropriate license agreement.
/// Creative Commons Licensees are subject to the
/// license found at
/// http://creativecommons.org/licenses/by-nc/2.5/
/// Single application licensees are subject to the license found at
/// http://www.jenkinssoftware.com/SingleApplicationLicense.html
/// Custom license users are subject to the terms therein.

#ifndef __UDP_PROXY_SERVER_H
#define __UDP_PROXY_SERVER_H

#include "Export.h"
#include "DS_Multilist.h"
#include "RakNetTypes.h"
#include "PluginInterface2.h"
#include "UDPForwarder.h"
#include "RakString.h"

namespace RakNet
{
class UDPProxyServer;

/// Callback to handle results of calling UDPProxyServer::LoginToCoordinator()
/// \ingroup UDP_PROXY_GROUP
struct UDPProxyServerResultHandler
{
	UDPProxyServerResultHandler() {}
	virtual ~UDPProxyServerResultHandler() {}

	/// Called when our login succeeds
	/// \param[out] usedPassword The password we passed to UDPProxyServer::LoginToCoordinator()
	/// \param[out] proxyServer The plugin calling this callback
	virtual void OnLoginSuccess(RakNet::RakString usedPassword, RakNet::UDPProxyServer *proxyServerPlugin)=0;

	/// We are already logged in.
	/// This login failed, but the system is operational as if it succeeded
	/// \param[out] usedPassword The password we passed to UDPProxyServer::LoginToCoordinator()
	/// \param[out] proxyServer The plugin calling this callback
	virtual void OnAlreadyLoggedIn(RakNet::RakString usedPassword, RakNet::UDPProxyServer *proxyServerPlugin)=0;

	/// The coordinator operator forgot to call UDPProxyCoordinator::SetRemoteLoginPassword()
	/// \param[out] usedPassword The password we passed to UDPProxyServer::LoginToCoordinator()
	/// \param[out] proxyServer The plugin calling this callback
	virtual void OnNoPasswordSet(RakNet::RakString usedPassword, RakNet::UDPProxyServer *proxyServerPlugin)=0;

	/// The coordinator operator set a different password in UDPProxyCoordinator::SetRemoteLoginPassword() than what we passed
	/// \param[out] usedPassword The password we passed to UDPProxyServer::LoginToCoordinator()
	/// \param[out] proxyServer The plugin calling this callback
	virtual void OnWrongPassword(RakNet::RakString usedPassword, RakNet::UDPProxyServer *proxyServerPlugin)=0;
};

/// \brief UDPProxyServer to control our instance of UDPForwarder
/// \details When NAT Punchthrough fails, it is possible to use a non-NAT system to forward messages from us to the recipient, and vice-versa.<BR>
/// The class to forward messages is UDPForwarder, and it is triggered over the network via the UDPProxyServer plugin.<BR>
/// The UDPProxyServer connects to UDPProxyServer to get a list of servers running UDPProxyServer, and the coordinator will relay our forwarding request.
/// \ingroup UDP_PROXY_GROUP
class RAK_DLL_EXPORT UDPProxyServer : public PluginInterface2
{
public:
	UDPProxyServer();
	~UDPProxyServer();

	/// Receives the results of calling LoginToCoordinator()
	/// Set before calling LoginToCoordinator or you won't know what happened
	/// \param[in] resultHandler 
	void SetResultHandler(UDPProxyServerResultHandler *rh);

	/// Before the coordinator will register the UDPProxyServer, you must login
	/// \pre Must be connected to the coordinator
	/// \pre Coordinator must have set a password with UDPProxyCoordinator::SetRemoteLoginPassword()
	/// \returns false if already logged in, or logging in. Returns true otherwise
	bool LoginToCoordinator(RakNet::RakString password, SystemAddress coordinatorAddress);

	/// Operative class that performs the forwarding
	/// Exposed so you can call UDPForwarder::SetMaxForwardEntries() if you want to change away from the default
	/// UDPForwarder::Startup(), UDPForwarder::Shutdown(), and UDPForwarder::Update() are called automatically by the plugin
	UDPForwarder udpForwarder;

	virtual void OnAttach(void);
	virtual void OnDetach(void);

	/// \internal
	virtual void Update(void);
	virtual PluginReceiveResult OnReceive(Packet *packet);
	virtual void OnClosedConnection(SystemAddress systemAddress, RakNetGUID rakNetGUID, PI2_LostConnectionReason lostConnectionReason );
	virtual void OnStartup(void);
	virtual void OnShutdown(void);

protected:
	void OnForwardingRequestFromCoordinatorToServer(Packet *packet);

	DataStructures::Multilist<ML_ORDERED_LIST, SystemAddress> loggingInCoordinators;
	DataStructures::Multilist<ML_ORDERED_LIST, SystemAddress> loggedInCoordinators;

	UDPProxyServerResultHandler *resultHandler;

};

} // End namespace

#endif
