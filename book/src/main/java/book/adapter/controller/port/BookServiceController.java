package book.adapter.controller.port;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;

import book.dto.Book;

import java.util.List;
import java.util.Optional;

import lombok.NonNull;
import lombok.RequiredArgsConstructor;
import lombok.NoArgsConstructor;
import lombok.ToString;

public interface BookServiceController {

    @ToString @NoArgsConstructor @RequiredArgsConstructor(staticName = "of")
    public class BooksRequest {
        public @NonNull Long readerId;
        public @NonNull Long bookIds[];
    }

    @GetMapping(value = "/books", 
        produces = MediaType.APPLICATION_JSON_VALUE)
    public List<Book> getBooks(
        @RequestParam("page") Optional<Integer> pageNum, 
        @RequestParam("size") Optional<Integer> pageSize,
        @RequestParam("reader") Optional<Long> readerId);

    @PostMapping(value = "/books/commands/load",
        produces = MediaType.APPLICATION_JSON_VALUE)
    public List<Book> loadDatabase(@RequestParam Optional<Integer> count);

    @PostMapping("/books/commands/cleanup")
    public String cleanUp(); 

    @PostMapping(value = "/books/commands/borrow",
        consumes = MediaType.APPLICATION_JSON_VALUE,
        produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<Object> borrowBooks(@RequestBody BooksRequest booksRequest);

    @PostMapping(value = "/books/commands/return",
        consumes = MediaType.APPLICATION_JSON_VALUE,
        produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<Object> returnBooks(@RequestBody BooksRequest booksRequest); 
}