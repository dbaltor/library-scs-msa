# Example of microservice-based application running on Tanzu Application Service (Former Pivotal Cloud Foundry)
<br>
This demo aims to show the power of Tanzu Application Service (TAS) platfom when it comes to run microservices developed using <a href="https://spring.io/projects/spring-cloud">Spring Cloud</a> umbrella project: <b>Spring Cloud Netflix</b>, <b>Spring Cloud OpenFeign</b>, <b>Spring Cloud Config</b> and <b>Spring Cloud Gateway</b>.
<br>
<br>
<img src="scMSA.png"> 
<br>
Each service binds to Eureka Server to discover all the others and start automatically using <i>client-side load balancing</i> through OpenFeign. The front-end service will configure accordingly its home page when running on Tanzu Application Service (TAS).<br>
Different Application Instances (AIs) will render the UI using different background colors, up to 4 different colors.<br>
<br>
You can generate 10 readers at a time clicking on the <i>Load Readers</i> button.<br>
You can generate 100 books at a time clicking on the <i>Load Books</i> button. The first 40 books will evenly be assigned to some readers.<br>
You can visualise the list of readers and books following the corresponding links. Use the browser's back buttom to return to the home page.<br>
<p/>
<p/>
<h2>Testing locally:</h2>
The build process requires that your workstation have Maven installed to used by the Spring Cloud Contract project. Execute the <code>./scripts/build.sh</code> script to build everything.<br>
<br>
Run the following commands to start everything up:<br>
<code>java -jar configserver/build/libs/configserver-1.0.0.jar</code><br>
<code>java -jar registry/build/libs/registry-1.0.0.jar</code><br>
<code>java -jar gateway/build/libs/gateway-1.0.0.jar</code><br>
<code>java -jar application/build/libs/application-1.0.0.jar</code><br>
<code>java -jar book/build/libs/book-1.0.0.jar</code><br>
<code>java -jar reader/build/libs/reader-1.0.0.jar</code><br>
<p/>
<p/>
<ins>URL:</ins><br>
localhost:8080
<p/>
<p/>
<h2>Testing in the cloud:</h2>
1. Install all required services and push the applications on TAS running the <code>./scripts/init.sh</code> script. If you just want to test the API gateway integrated with <b>Tanzu API Portal</b> without databases being provisioned, run instead the <code>./scripts/init-api.sh &ltpath-to-api-portal-jar-file&gt</code> script, passing in the path to the API Portal jar file downloaded from the Tanzu Network.<br>
<br>
2. Use the published route to access the application running on TAS. You will notice that the home page looks different now. The application has detected it is running on TAS :) <br>
<ins>URL:</ins><br>
<code>https://library-msa.&ltapps-domain&gt/</code><br>
<br>
3. Generate some data clicking on <i>Load Readers</i> and <i>Load Books</i> buttons.<br>
<br>
4. Scale out the front-end application via the <code>cf scale app library-msa -i 3</code> command.<br>
<br>
5. Stop the <b>Reader</b> service instance using the <code>cf stop library-reader-service</code> command.<br>
<br>
6. You can verify that the <b>Reader</b> service instance is gone clicking on the <i>List of Readers</i> link on the home page. The list shows up empty.<br>
<br>
7. Navigate to the <i>List of Books</i> page. Borrow a book to some reader who hasn't yet borrowed any books. The operation is to succeed despite the <b>Reader</b> service being down. This is the <i>circuit breaker pattern</i> in action.<br>
<br>
8. You can access the back-end services RESTful APIs via the <b>API Gateway</b>. For example, retrieve the list of books using the <code>http https://library-gtw.&ltapps-domain&gt/library-book-service/books</code> command.<br>
<br>
9. (Optional) If you installed the <b>API Portal</b> on step 1, now you can access it at the <code>https://api.&ltapps-domain&gt/</code> route.<br>
<p/>
<p/>
<h2>Cleaning up:</h2>
<br>
10. Run either <code>./scripts/cleanup.sh</code> or <code>./scripts/cleanup-api.sh</code> script depending on whether or not you deployed the <b>API Portal</b> on step 1.<br>
<p/>
<p/>
<h2>Architectural Decisions:</h2>
<br>
1) The application follows the microservice architecture pattern and the back-end services expose RESTful APIs. The front-end service implements the Model-View-Controller (MVC) architectural pattern which is made easy by the Spring framework.<br> 
<br>
2) The front-end service can easily consume the RESTful APIs thanks to the declarative model offered by the Spring Cloud OpenFeign library.<br>
<br>
3) This microservice architecture leverages a <b>service registry</b>, <b>config server</b> and <b>API gateway</b>, all of them implemented using the Spring Cloud umbrella project.<br>
<br>
4) SQL databases have been chosen as data stores. Both <b>Reader</b> and <b>Book</b> services use H2 embedded in-memory database by default when running locally.<br>
