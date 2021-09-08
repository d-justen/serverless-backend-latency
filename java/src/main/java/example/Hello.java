package example;

import java.util.*;
import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.RequestHandler;

public class Hello implements RequestHandler<Map<String, String>, String> {
	@Override
	public String handleRequest(Map<String, String> event, Context context) {
		return "Hello, world!";
	}
}

