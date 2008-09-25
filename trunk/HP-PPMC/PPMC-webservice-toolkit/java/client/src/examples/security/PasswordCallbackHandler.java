package examples.security;

import java.io.IOException;
import javax.security.auth.callback.Callback;
import javax.security.auth.callback.CallbackHandler;
import javax.security.auth.callback.UnsupportedCallbackException;
import org.apache.ws.security.WSPasswordCallback;

/**
 * Test class to set user's password
 * 
 * @author kwang
 *
 */
public class PasswordCallbackHandler implements CallbackHandler {
    String username = null;
    public void handle(Callback[] callbacks) throws IOException,
            UnsupportedCallbackException {

        for (int i = 0; i < callbacks.length; i++) {
            WSPasswordCallback callback = (WSPasswordCallback)callbacks[i];
                               
            // obtain password. This can be customized to obtain
            // password from any desire source and apply any
            // necessary algorithm.
            //
            // if your logic requires the username, you can get the
            // user name by:
            //    String username = callback.getIdentifier();
            //
            String password = "admin";
                         
      
            // set the obtained password
            callback.setPassword(password);
        }
    }
}
