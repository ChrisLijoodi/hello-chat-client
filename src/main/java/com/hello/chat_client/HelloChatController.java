package com.hello.chat_client;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.ai.chat.client.ChatClient;
import org.springframework.ai.tool.ToolCallbackProvider;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Arrays;

@RestController
public class HelloChatController {
    private static final Logger log = LoggerFactory.getLogger(HelloChatController.class);
    private final ChatClient chatClient;
    public HelloChatController(ChatClient.Builder builder, ToolCallbackProvider tools) {
        Arrays.stream(tools.getToolCallbacks()).forEach(toolCallback -> {
            log.info("Tool callback found: {}",toolCallback.getToolDefinition());
        });
        this.chatClient = builder
                .defaultToolCallbacks(tools)
                .build();
    }

    @GetMapping("/hello")
    public String chat(){
        log.info("hello greetings called!");
        return chatClient.prompt()
                .user("List the greetings")
                .call().content();
    }
}
